#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <queue>
#include <chrono>

using namespace std;
using namespace std::chrono;

#define ll long long

string get_arg(int argc, char *argv[], string arg_name) {
    for (int i = 1; i < argc; i++) {
        string arg_i = argv[i];
        if (arg_i == arg_name && i + 1 < argc) {
            string arg = argv[i + 1];
            return arg;
        }
    }
    return "";
}

int main(int argc, char *argv[]) {
    string graph_name = "100K";

    string arg;
    int temp;

    arg = get_arg(argc, argv, "-g");
    if (arg != "") graph_name = arg;

    ios_base::sync_with_stdio(false);
    cin.tie(NULL);
    cout.tie(NULL);

    string filename = "connected_graph_" + graph_name + ".txt";
    string output_file_name = "output_SEQ_" + graph_name + ".txt";

    vector<vector<ll>> adj;

    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Error opening file: " << filename << endl;
        return 1;
    }

    int n = 0;

    string line;
    while (getline(file, line)) {
        if (!line.empty()) {
            istringstream iss(line);
            vector<ll> neighbors;
            ll neighbor;

            while (iss >> neighbor) {
                neighbors.push_back(neighbor);
            }

            adj.push_back(neighbors);
            n++;
        }
    }

    queue<ll> q;
    vector<bool> visited(n, false);
    vector<ll> distance(n, 0);

    ll src = 0; // Change this according to your source node

    visited[src] = true;
    distance[src] = 0;
    q.push(src);

    auto start_time = high_resolution_clock::now();

    while (!q.empty()) {
        ll s = q.front();
        q.pop();
        for (auto u : adj[s]) {
            if (visited[u]) continue;
            visited[u] = true;
            distance[u] = distance[s] + 1;
            q.push(u);
        }
    }

    auto stop_time = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop_time - start_time);

    ofstream output_file(output_file_name);

    if (!output_file.is_open()) {
        cerr << "Error: Unable to open output file." << endl;
        return 1;
    }

    output_file << "BFS Execution Time: " << duration.count() / 1000.0 << " milliseconds" << endl;

    for (ll i = 0; i < n; ++i) {
        output_file << "Distance to node " << i << ": " << distance[i] << endl;
    }

    output_file.close();

    return 0;
}
