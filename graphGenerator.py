import networkx as nx

def generate_connected_graph(num_vertices):
    G = nx.connected_watts_strogatz_graph(num_vertices, k=4, p=0.1)
    return G

def export_adjacency_list(graph, filename):
    with open(filename, 'w') as file:
        for node in graph.nodes:
            neighbors = ' '.join(map(str, graph.neighbors(node)))
            file.write(neighbors + '\n')

if __name__ == "__main__":
    num_vertices = 1000000
    output_filename = "connected_graph.txt"

    connected_graph = generate_connected_graph(num_vertices)
    export_adjacency_list(connected_graph, output_filename)

    print(f"Connected graph with {num_vertices} vertices generated and saved to {output_filename}.")
