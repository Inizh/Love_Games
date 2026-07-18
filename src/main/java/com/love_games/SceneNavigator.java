package com.love_games;

import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;
import java.util.Objects;
import java.util.function.Consumer;

/**
 * Central place to switch scenes so every screen shares the same stage & stylesheet.
 */
public final class SceneNavigator {

    public static final double DEFAULT_WIDTH = 720;
    public static final double DEFAULT_HEIGHT = 800;

    private final Stage stage;
    private final String stylesheet;

    public SceneNavigator(Stage stage) {
        this.stage = Objects.requireNonNull(stage);
        this.stylesheet = Objects.requireNonNull(
                Main.class.getResource("styles.css"),
                "styles.css missing"
        ).toExternalForm();
    }

    public Stage getStage() {
        return stage;
    }

    public void showHome() {
        load("home-page.fxml", "Love Games", DEFAULT_WIDTH, 640, null);
    }

    public void showFlames() {
        load("flames-page.fxml", "FLAMES — Love Games", DEFAULT_WIDTH, 720, null);
    }

    public void showChat() {
        load("chat-page.fxml", "Chat — Love Games", 700, 820, null);
    }

    public <T> void load(String fxml, String title, double width, double height, Consumer<T> afterLoad) {
        try {
            FXMLLoader loader = new FXMLLoader(Main.class.getResource(fxml));
            Parent root = loader.load();
            Object controller = loader.getController();
            if (controller instanceof Navigable navigable) {
                navigable.setNavigator(this);
            }
            if (afterLoad != null) {
                @SuppressWarnings("unchecked")
                T typed = (T) controller;
                afterLoad.accept(typed);
            }
            Scene scene = stage.getScene();
            if (scene == null) {
                scene = new Scene(root, width, height);
                scene.getStylesheets().add(stylesheet);
                stage.setScene(scene);
            } else {
                scene.setRoot(root);
                if (!scene.getStylesheets().contains(stylesheet)) {
                    scene.getStylesheets().add(stylesheet);
                }
                stage.setWidth(width);
                stage.setHeight(height);
            }
            stage.setTitle(title);
            stage.setMinWidth(480);
            stage.setMinHeight(560);
            if (!stage.isShowing()) {
                stage.show();
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load " + fxml, e);
        }
    }

    /** Controllers implement this to receive the navigator after FXML load. */
    public interface Navigable {
        void setNavigator(SceneNavigator navigator);
    }
}
