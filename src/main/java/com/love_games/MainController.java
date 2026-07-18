package com.love_games;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class MainController implements SceneNavigator.Navigable {

    private SceneNavigator navigator;

    @FXML
    private Label subtitleLabel;

    @Override
    public void setNavigator(SceneNavigator navigator) {
        this.navigator = navigator;
    }

    @FXML
    private void openFlames() {
        if (navigator != null) {
            navigator.showFlames();
        }
    }

    @FXML
    private void openChat() {
        if (navigator != null) {
            navigator.showChat();
        }
    }
}
