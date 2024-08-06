import chromadb


class Retriever:
    def __init__(self, collection_name : str, client : chromadb.HttpClient) -> None:
        self.client = client
        self.collection_name = collection_name  
        self.collection = self.client.get_collection(name=self.collection_name) 

    def retrieve(self, query : str, n_results : int = 3) -> list:
        result = self.collection.query(query_texts=[query], 
                                     n_results=n_results, 
                                     include=['documents', 'metadatas'])
        result_filenames = [entry['filename'] for entry in result['metadatas'][0]]
        names_and_documents = tuple(zip(result_filenames, result['documents'][0]))
        return names_and_documents

