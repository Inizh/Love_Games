import java.util.Scanner;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.util.concurrent.CompletionStage;

public class ChatInterface extends Game
{
    protected String userName;
    protected HttpClient client;
    protected WebSocket webSocket;
    public ChatInterface(Scanner cin ) {
        super(cin);
        System.out.print("Enter your name: ");
        userName = cin.nextLine();
        client = HttpClient.newHttpClient();
        webSocket = client.newWebSocketBuilder()
                .buildAsync(URI.create("ws://localhost:8080/ws/" + userName) , new WebSocketListener())
                .join();
        System.out.println("Connected");

    }

    public void run(){
        welcome();
        while(true){
            String message = cin.nextLine();
            if("exit".equals(message)) break;
            webSocket.sendText(message , true);
        }

    }


    private void welcome(){
        System.out.println("Welcome to Chat Interface");
    }
}


class WebSocketListener implements WebSocket.Listener {
    @Override
    public void onError(WebSocket webSocket, Throwable error) {
        System.out.println("Error: " + error.getMessage());
        WebSocket.Listener.super.onError(webSocket, error);
    }

    @Override
    public CompletionStage<?> onText(WebSocket webSocket, CharSequence data, boolean last) {
        System.out.println("\n[Message]: " + data);
        return WebSocket.Listener.super.onText(webSocket, data, last);
    }

    @Override
    public void onOpen(WebSocket webSocket) {
        WebSocket.Listener.super.onOpen(webSocket);
    }
}
