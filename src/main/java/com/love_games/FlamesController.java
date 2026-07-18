package com.love_games;

import javafx.animation.FadeTransition;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;
import javafx.util.Duration;

public class FlamesController implements SceneNavigator.Navigable {

    private SceneNavigator navigator;

    @FXML private TextField herNameField;
    @FXML private TextField hisNameField;
    @FXML private Label resultLetterLabel;
    @FXML private Label resultTitleLabel;
    @FXML private Label resultDescLabel;
    @FXML private Label hintLabel;
    @FXML private VBox resultCard;

    @Override
    public void setNavigator(SceneNavigator navigator) {
        this.navigator = navigator;
    }

    @FXML
    private void initialize() {
        resultCard.setVisible(false);
        resultCard.setManaged(false);
        herNameField.setOnAction(e -> calculate());
        hisNameField.setOnAction(e -> calculate());
    }

    @FXML
    private void calculate() {
        Flames.Result result = Flames.calculate(herNameField.getText(), hisNameField.getText());

        if (result.isEmpty()) {
            hintLabel.setText(result.description().isEmpty()
                    ? "Please enter both names."
                    : result.description());
            resultCard.setVisible(false);
            resultCard.setManaged(false);
            return;
        }

        hintLabel.setText(result.herName() + "  ×  " + result.hisName());
        resultLetterLabel.setText(String.valueOf(result.letter()));
        resultTitleLabel.setText(result.label());
        resultDescLabel.setText(result.description());

        resultCard.setVisible(true);
        resultCard.setManaged(true);
        resultCard.setOpacity(0);
        FadeTransition fade = new FadeTransition(Duration.millis(450), resultCard);
        fade.setFromValue(0);
        fade.setToValue(1);
        fade.play();
    }

    @FXML
    private void clearForm() {
        herNameField.clear();
        hisNameField.clear();
        hintLabel.setText("Enter two names and discover your fate.");
        resultCard.setVisible(false);
        resultCard.setManaged(false);
        herNameField.requestFocus();
    }

    @FXML
    private void goHome() {
        if (navigator != null) {
            navigator.showHome();
        }
    }
}
