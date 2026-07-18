package com.love_games;

import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;

public class ChatController implements SceneNavigator.Navigable {

    private SceneNavigator navigator;
    private final ChatClient chatClient = new ChatClient();
    private String userName = "You";

    @FXML private StackPane rootStack;
    @FXML private VBox loginPane;
    @FXML private VBox chatPane;
    @FXML private TextField nameField;
    @FXML private Label loginStatusLabel;
    @FXML private Label headerNameLabel;
    @FXML private Label statusLabel;
    @FXML private Circle statusDot;
    @FXML private ScrollPane scrollPane;
    @FXML private VBox messagesBox;
    @FXML private TextField messageField;
    @FXML private Button sendButton;
    @FXML private Button connectButton;

    @Override
    public void setNavigator(SceneNavigator navigator) {
        this.navigator = navigator;
    }

    @FXML
    private void initialize() {
        showLogin(true);
        messageField.setOnAction(e -> sendMessage());
        nameField.setOnAction(e -> connect());

        messagesBox.heightProperty().addListener((obs, oldVal, newVal) ->
                scrollPane.setVvalue(1.0));

        chatClient.setOnMessage(this::handleIncoming);
        chatClient.setOnStatus(status -> {
            statusLabel.setText(status);
            loginStatusLabel.setText(status);
            boolean ok = status.toLowerCase().startsWith("connected");
            statusDot.setFill(Color.web(ok ? "#00b894" : "#fdcb6e"));
            if (status.toLowerCase().contains("fail") || status.toLowerCase().contains("error")
                    || status.equalsIgnoreCase("Disconnected")) {
                statusDot.setFill(Color.web("#d63031"));
                setChatEnabled(false);
            }
            if (ok) {
                setChatEnabled(true);
            }
        });
        chatClient.setOnError(err -> {
            loginStatusLabel.setText("Could not connect: " + err.getMessage());
            statusDot.setFill(Color.web("#d63031"));
            setChatEnabled(false);
        });

        setChatEnabled(false);
    }

    @FXML
    private void connect() {
        String name = nameField.getText() == null ? "" : nameField.getText().trim();
        if (name.isEmpty()) {
            loginStatusLabel.setText("Please enter your name.");
            return;
        }
        userName = name;
        connectButton.setDisable(true);
        loginStatusLabel.setText("Connecting…");

        chatClient.connect(name).whenComplete((v, err) -> Platform.runLater(() -> {
            connectButton.setDisable(false);
            if (chatClient.isConnected()) {
                headerNameLabel.setText(userName);
                showLogin(false);
                messagesBox.getChildren().clear();
                addSystemMessage("Connected. Say hi to the room!");
                messageField.requestFocus();
            }
        }));
    }

    @FXML
    private void sendMessage() {
        String text = messageField.getText() == null ? "" : messageField.getText().trim();
        if (text.isEmpty()) {
            return;
        }
        if (!chatClient.isConnected()) {
            addSystemMessage("Not connected. Go back and reconnect.");
            return;
        }
        if ("exit".equalsIgnoreCase(text)) {
            disconnectAndHome();
            return;
        }
        chatClient.send(userName + ": " + text);
        addSentMessage(text);
        messageField.clear();
    }

    @FXML
    private void goHome() {
        disconnectAndHome();
    }

    @FXML
    private void disconnectOnly() {
        chatClient.disconnectQuietly();
        showLogin(true);
        loginStatusLabel.setText("Disconnected. Enter your name to rejoin.");
        statusDot.setFill(Color.web("#b2bec3"));
        setChatEnabled(false);
    }

    private void disconnectAndHome() {
        chatClient.disconnectQuietly();
        if (navigator != null) {
            navigator.showHome();
        }
    }

    private void handleIncoming(String raw) {
        // Server broadcasts: "Message received: <payload>" or disconnect notices
        String payload = raw;
        if (raw.startsWith("Message received: ")) {
            payload = raw.substring("Message received: ".length());
        }

        // Don't echo our own bubble twice if server rebroadcasts "Name: text"
        String selfPrefix = userName + ": ";
        if (payload.startsWith(selfPrefix)) {
            // Already shown as sent bubble — optional: skip or show as room echo.
            // Show as room echo only if we want multi-user confirmation; skip for cleaner UX.
            return;
        }

        if (raw.toLowerCase().contains("disconnected")) {
            addSystemMessage(raw);
            return;
        }

        addReceivedMessage(payload);
    }

    private void showLogin(boolean login) {
        loginPane.setVisible(login);
        loginPane.setManaged(login);
        chatPane.setVisible(!login);
        chatPane.setManaged(!login);
    }

    private void setChatEnabled(boolean enabled) {
        messageField.setDisable(!enabled);
        sendButton.setDisable(!enabled);
    }

    private void addSentMessage(String message) {
        messagesBox.getChildren().add(createBubble(message, BubbleKind.SENT));
    }

    private void addReceivedMessage(String message) {
        messagesBox.getChildren().add(createBubble(message, BubbleKind.RECEIVED));
    }

    private void addSystemMessage(String message) {
        messagesBox.getChildren().add(createBubble(message, BubbleKind.SYSTEM));
    }

    private enum BubbleKind { SENT, RECEIVED, SYSTEM }

    private HBox createBubble(String message, BubbleKind kind) {
        Label label = new Label(message);
        label.setWrapText(true);
        label.setMaxWidth(kind == BubbleKind.SYSTEM ? 480 : 340);

        HBox box = new HBox();
        box.setMaxWidth(Double.MAX_VALUE);

        switch (kind) {
            case SENT -> {
                label.getStyleClass().addAll("bubble", "bubble-sent");
                box.setAlignment(Pos.CENTER_RIGHT);
            }
            case RECEIVED -> {
                label.getStyleClass().addAll("bubble", "bubble-received");
                box.setAlignment(Pos.CENTER_LEFT);
            }
            case SYSTEM -> {
                label.getStyleClass().addAll("bubble", "bubble-system");
                box.setAlignment(Pos.CENTER);
            }
        }

        box.getChildren().add(label);
        return box;
    }
}
