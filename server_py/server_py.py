import socket
import json

# クライアントからの接続を待つ関数
def wait_for_connection(server_socket):
    print(f"Waiting for connection...")
    conn, addr = server_socket.accept()
    print(f"Connection from {addr}")
    return conn, addr

def main():
    host = 'localhost'  # ホスト名
    port = 12345         # ポート番号

    # ソケットオブジェクトの作成
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # アドレスのバインド
    server_socket.bind((host, port))
    
    # 接続の待機 (最大1接続)
    server_socket.listen(1)
    print(f"Listening for connections on {host}:{port}...")

    conn, addr = wait_for_connection(server_socket)  # 接続待ち

    while True:
        # データの受信 (最大1024バイト)
        data = conn.recv(1024)
        
        # データがない場合は再度接続待ち
        if not data:
            print("Connection lost. Waiting for reconnection.")
            conn, addr = wait_for_connection(server_socket)  # 再接続待ち
            continue
        
        # 受信データをデコードしてJSONに変換
        decoded_data = data.decode('utf-8')
        json_data = json.loads(decoded_data)
        
        # 受信データを表示
        print(f"Received data: {json_data}")

    # 接続のクローズ（通常、この行は到達しない）
    conn.close()

if __name__ == "__main__":
    main()
