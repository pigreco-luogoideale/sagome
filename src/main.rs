slint::include_modules!();

use slint::{Image, Model, ModelRc, SharedString, VecModel};
use std::cell::RefCell;
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::rc::Rc;

// Each puzzle lists layer IDs in bottom-to-top stacking order.
const PUZZLES: &[&[&str]] = &[
    &["001", "002", "003"],
    &["002", "004"],
    &["001", "003", "005"],
];

struct Game {
    layers_dir: PathBuf,
    available_layers: Vec<String>,
    solution: Vec<String>,
    selected: Vec<String>,
    puzzle_idx: usize,
    image_cache: HashMap<String, Image>,
}

impl Game {
    fn new(layers_dir: PathBuf) -> Self {
        let mut game = Game {
            layers_dir,
            available_layers: Vec::new(),
            solution: Vec::new(),
            selected: Vec::new(),
            puzzle_idx: 0,
            image_cache: HashMap::new(),
        };
        game.load_puzzle(0);
        game
    }

    fn load_puzzle(&mut self, idx: usize) {
        self.puzzle_idx = idx;
        self.selected.clear();
        self.solution = PUZZLES[idx].iter().map(|s| s.to_string()).collect();

        let mut available: Vec<String> = std::fs::read_dir(&self.layers_dir)
            .expect("layers directory not found")
            .filter_map(|e| e.ok())
            .filter_map(|e| {
                let name = e.file_name().into_string().ok()?;
                name.ends_with(".svg")
                    .then(|| name.trim_end_matches(".svg").to_string())
            })
            .collect();
        available.sort();
        self.available_layers = available;

        for id in self.available_layers.clone() {
            if !self.image_cache.contains_key(&id) {
                let path = self.layers_dir.join(format!("{}.svg", id));
                let img = Image::load_from_path(&path).unwrap_or_default();
                self.image_cache.insert(id, img);
            }
        }
    }

    fn next_puzzle(&mut self) {
        let next = (self.puzzle_idx + 1) % PUZZLES.len();
        self.load_puzzle(next);
    }

    fn get_image(&self, id: &str) -> Image {
        self.image_cache.get(id).cloned().unwrap_or_default()
    }

    fn toggle_layer(&mut self, id: &str) {
        if let Some(pos) = self.selected.iter().position(|s| s == id) {
            self.selected.remove(pos);
        } else {
            self.selected.push(id.to_string());
        }
    }

    fn reset(&mut self) {
        self.selected.clear();
    }

    fn is_solved(&self) -> bool {
        self.selected == self.solution
    }

    fn build_layer_models(&self) -> Vec<LayerInfo> {
        self.available_layers
            .iter()
            .map(|id| {
                let order = self
                    .selected
                    .iter()
                    .position(|s| s == id)
                    .map(|i| (i + 1) as i32)
                    .unwrap_or(0);
                LayerInfo {
                    id: SharedString::from(id.as_str()),
                    image: self.get_image(id),
                    selection_order: order,
                }
            })
            .collect()
    }

    fn composite_stack(&self) -> Vec<LayerInfo> {
        self.selected
            .iter()
            .enumerate()
            .map(|(i, id)| LayerInfo {
                id: SharedString::from(id.as_str()),
                image: self.get_image(id),
                selection_order: (i + 1) as i32,
            })
            .collect()
    }

    fn target_stack(&self) -> Vec<LayerInfo> {
        self.solution
            .iter()
            .enumerate()
            .map(|(i, id)| LayerInfo {
                id: SharedString::from(id.as_str()),
                image: self.get_image(id),
                selection_order: (i + 1) as i32,
            })
            .collect()
    }
}

fn main() {
    let layers_dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("layers");
    let game: Rc<RefCell<Game>> = Rc::new(RefCell::new(Game::new(layers_dir)));

    let ui = AppWindow::new().unwrap();

    let layer_model: Rc<VecModel<LayerInfo>> = Rc::new(VecModel::default());
    ui.set_layers(ModelRc::from(layer_model.clone()));

    // Full sync: rebuilds layer model and updates all UI properties.
    let sync = {
        let game = game.clone();
        let layer_model = layer_model.clone();
        let ui_handle = ui.as_weak();
        move || {
            let g = game.borrow();
            let new_layers = g.build_layer_models();

            // Resize model if puzzle changed
            while layer_model.row_count() > new_layers.len() {
                layer_model.remove(layer_model.row_count() - 1);
            }
            for (i, layer) in new_layers.into_iter().enumerate() {
                if i < layer_model.row_count() {
                    layer_model.set_row_data(i, layer);
                } else {
                    layer_model.push(layer);
                }
            }

            if let Some(ui) = ui_handle.upgrade() {
                ui.set_target_stack(ModelRc::from(Rc::new(VecModel::from(g.target_stack()))));
                ui.set_composite_stack(ModelRc::from(Rc::new(VecModel::from(g.composite_stack()))));
                ui.set_solved(g.is_solved());
            }
        }
    };
    let sync = Rc::new(sync);

    sync(); // initial population

    ui.on_layer_clicked({
        let game = game.clone();
        let sync = sync.clone();
        move |idx| {
            let id = game.borrow().available_layers[idx as usize].clone();
            game.borrow_mut().toggle_layer(&id);
            sync();
        }
    });

    ui.on_reset_clicked({
        let game = game.clone();
        let sync = sync.clone();
        move || {
            game.borrow_mut().reset();
            sync();
        }
    });

    ui.on_next_level_clicked({
        let game = game.clone();
        let sync = sync.clone();
        move || {
            game.borrow_mut().next_puzzle();
            sync();
        }
    });

    ui.run().unwrap();
}
