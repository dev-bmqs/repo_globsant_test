from flask import Flask, request, jsonify
import pandas as pd
import sqlite3

app = Flask(__name__)

@app.route('/upload-csv', methods=['POST'])
def upload_files():
    # Verifica se foram enviados arquivos na requisição
    if 'arquivos' not in request.files:
        return jsonify({'error': 'No file part in the request'}), 400

    files = request.files.getlist('arquivos')

    # Verifica se algum arquivo foi selecionado
    if not files:
        return jsonify({'error': 'No files selected'}), 400

    filenames = []

    for file in files:
        # Verifica se o arquivo é do tipo CSV
        if file.filename == '':
            return jsonify({'error': 'File name cannot be empty'}), 400

        # Nome do arquivo
        filename = file.filename
        filenames.append(filename)

        # Processamento do arquivo
        try:
            # Lê o arquivo CSV usando a biblioteca pandas
            df = pd.read_csv(file)
            
            #Insere os Arquivos no SQL Lite
            with sqlite3.connect('database.db') as conn:
                df.to_sql(f'{filename}', conn, if_exists='replace', index=False)
                
            print(f'Arquivo: {filename}')
            print(df)

        except Exception as e:
            # Em caso de erro no processamento, retorna uma mensagem
            return jsonify({'error': f'Error processing file {filename}: {str(e)}'}), 500

    return jsonify({'filenames': filenames, 'message': 'Files received successfully'}), 200

def execute_select_query(query):
    try:
        # Conecta-se ao banco de dados SQLite
        conn = sqlite3.connect('database.db')
        cursor = conn.cursor()

        # Executa a consulta SQL
        cursor.execute(query)

        # Recupera os resultados da consulta
        results = cursor.fetchall()

        # Fecha a conexão com o banco de dados
        cursor.close()
        conn.close()

        return results

    except Exception as e:
        print(f'Error executing query: {str(e)}')
        return None

# Rota para executar a consulta SELECT e retornar os resultados
@app.route('/query', methods=['POST'])
def execute_query():
    data = request.json

    if 'query' not in data:
        return jsonify({'error': 'Query not provided'}), 400

    query = data['query']
    results = execute_select_query(query)

    if results:
        # Transforma os resultados
        return results
    else:
        return jsonify({'error': 'Error executing query'}), 500

if __name__ == '__main__':
    app.run(debug=True)
