package com.love_games;

import javafx.application.Platform;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.CompletableFuture;
import java.util.function.Consumer;

/**
 * WebSocket client for the FastAPI chat server (ws://localhost:8080/ws/{name}).
 */
public final class ChatClient implements AutoCloseable {

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private WebSocket webSocket;
    private Consumer<String> onMessage = msg -> {};
    private Consumer<String> onStatus = status -> {};
    private Consumer<Throwable> onError = err -> {};
    private volatile boolean connected;

    public void setOnMessage(Consumer<String> onMessage) {
        this.onMessage = onMessage != null ? onMessage : msg -> {};
    }

    public void setOnStatus(Consumer<String> onStatus) {
        this.onStatus = onStatus != null ? onStatus : status -> {};
    }

    public void setOnError(Consumer<Throwable> onError) {
        this.onError = onError != null ? onError : err -> {};
    }

    public boolean isConnected() {
        return connected;
    }

    public CompletableFuture<Void> connect(String userName) {
        disconnectQuietly();
        String trimmed = userName == null ? "" : userName.trim().replaceAll("\\s+", "_");
        final String safeName = trimmed.isEmpty() ? "guest" : trimmed;

        String url = "ws://localhost:8080/ws/" + safeName;
        notifyStatus("Connecting to " + url + "…");

        return httpClient.newWebSocketBuilder()
                .buildAsync(URI.create(url), new Listener())
                .thenAccept(ws -> {
                    this.webSocket = ws;
                    this.connected = true;
                    notifyStatus("Connected as " + safeName);
                })
                .exceptionally(ex -> {
                    connected = false;
                    Throwable cause = ex.getCause() != null ? ex.getCause() : ex;
                    notifyError(cause);
                    notifyStatus("Connection failed — is the chat server running?");
                    return null;
                });
    }

    public void send(String message) {
        if (webSocket == null || !connected) {
            notifyStatus("Not connected.");
            return;
        }
        webSocket.sendText(message, true);
    }

    public void disconnectQuietly() {
        connected = false;
        if (webSocket != null) {
            try {
                webSocket.sendClose(WebSocket.NORMAL_CLOSURE, "bye");
            } catch (Exception ignored) {
                // ignore close failures
            }
            webSocket = null;
        }
    }

    @Override
    public void close() {
        disconnectQuietly();
    }

    private void notifyStatus(String status) {
        Platform.runLater(() -> onStatus.accept(status));
    }

    private void notifyError(Throwable error) {
        Platform.runLater(() -> onError.accept(error));
    }

    private void notifyMessage(String message) {
        Platform.runLater(() -> onMessage.accept(message));
    }

    private final class Listener implements WebSocket.Listener {
        private final StringBuilder buffer = new StringBuilder();

        @Override
        public void onOpen(WebSocket webSocket) {
            WebSocket.Listener.super.onOpen(webSocket);
            webSocket.request(1);
        }

        @Override
        public CompletionStage<?> onText(WebSocket webSocket, CharSequence data, boolean last) {
            buffer.append(data);
            if (last) {
                String full = buffer.toString();
                buffer.setLength(0);
                notifyMessage(full);
            }
            webSocket.request(1);
            return null;
        }

        @Override
        public void onError(WebSocket webSocket, Throwable error) {
            connected = false;
            notifyError(error);
            notifyStatus("Connection error: " + error.getMessage());
            WebSocket.Listener.super.onError(webSocket, error);
        }

        @Override
        public CompletionStage<?> onClose(WebSocket webSocket, int statusCode, String reason) {
            connected = false;
            notifyStatus("Disconnected");
            return WebSocket.Listener.super.onClose(webSocket, statusCode, reason);
        }
    }
}
