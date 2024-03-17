#include <cuda.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <iostream>
#include <climits>
#include <fstream>
#include <sstream>
#include <chrono>

using namespace std;

#define ll long long

void read_adj_list(const string& filename, thrust::host_vector<ll>& h_c, thrust::host_vector<ll>& h_r) {
    ifstream file(filename);
    string line;

    ll row_pointer = 0;
    h_r.push_back(row_pointer);

    while (getline(file, line)) {
        istringstream iss(line);
        ll neighbor;

        while (iss >> neighbor) {
            h_c.push_back(neighbor);
        }

        row_pointer = h_c.size();

        h_r.push_back(row_pointer);
    }
    h_r.pop_back();
}

__global__
void bfs(ll *d_c, ll *d_r, ll *d_dist, bool *d_change, ll *d_n){
    ll thread  = blockIdx.x * blockDim.x + threadIdx.x;

    if(thread >= *d_n) return;

    for(ll i = d_r[thread]; i < d_r[thread+1]; i++){
        ll u = d_c[i];

        if(d_dist[u] > d_dist[thread]+1){
            d_dist[u] = d_dist[thread]+1;
            *d_change = 1;
        }
    }
}

string get_arg(int argc, char *argv[], string arg_name){
    for(int i = 1; i < argc; i++){
        string arg_i = argv[i];
        if(arg_i == arg_name && i+1 < argc){
            string arg = argv[i+1];
            return arg;
        }
    }
    return "";
}

int main(int argc, char *argv[]){
    int block_size = 1024;
    string graph_name = "100K";

    string arg;
    int temp;

    arg = get_arg(argc,argv,"-bs");
    if(arg != "" && (temp=stoi(arg))!=0) block_size = temp;

    arg = get_arg(argc,argv,"-g");
    if(arg != "") graph_name = arg;

    ios_base::sync_with_stdio(false);
    cin.tie(NULL);
    cout.tie(NULL);

    string filename = "connected_graph_"+graph_name+".txt";
    string output_file_name = "output_"+graph_name+"_"+to_string(block_size)+".txt";

    thrust::host_vector<ll> h_c, h_r;

    read_adj_list(filename, h_c, h_r);


    ll n = h_r.size();
    ll src = 0;

    // Some dummy vector to wake up device
    thrust::device_vector<int> dummy_vec (1000000, 1);

    output_file.close();

    thrust::device_vector<ll> d_c(h_c);

    thrust::device_vector<ll> d_r(h_r);

    thrust::device_vector<ll> d_dist(n, n-1);
    d_dist[src] = 0;

    ll *d_n;
    cudaMalloc((void**)&d_n , sizeof(ll));
    cudaMemcpy(d_n, &n, sizeof(ll), cudaMemcpyHostToDevice);

    bool change;

    bool *d_change;
    cudaMalloc((void**)&d_change , sizeof(bool));

    auto stop_time_cpy = chrono::high_resolution_clock::now();
    auto duration_cpy = chrono::duration_cast<chrono::microseconds>(stop_time_cpy - start_time_cpy);

    auto start_time_kernel = chrono::high_resolution_clock::now();

    do {
        change = 0;
        cudaMemcpy(d_change, &change, sizeof(bool), cudaMemcpyHostToDevice);

        bfs<<<(n/block_size)+1, block_size>>>(thrust::raw_pointer_cast(d_c.data()), thrust::raw_pointer_cast(d_r.data()), thrust::raw_pointer_cast(d_dist.data()), d_change, d_n);
        cudaDeviceSynchronize();

        cudaError_t err = cudaGetLastError();
        if (err) {
            cerr << "Error: " << cudaGetErrorString(err) << "\n";
            return 1;
        }

        cudaMemcpy(&change, d_change, sizeof(bool), cudaMemcpyDeviceToHost);
    } while(change);

    auto stop_time_kernel = chrono::high_resolution_clock::now();
    auto duration_kernel = chrono::duration_cast<chrono::microseconds>(stop_time_kernel - start_time_kernel);

    ofstream output_file(output_file_name);

    if (!output_file.is_open()) {
        cerr << "Error: Unable to open output file." << endl;
        return 1;
    }

    output_file << "BFS Execution Time Kernel: " << duration_kernel.count()/1000.0 << " milliseconds" << endl;

    output_file << "BFS Execution Time FULL: " << duration_kernel.count()/1000.0+duration_cpy.count()/1000.0 << " milliseconds" << endl;

    thrust::device_vector<ll> dist(d_dist.begin(), d_dist.end());

    for (ll i = 0; i < n; ++i) {
        output_file << "Distance to node " << i << ": " << dist[i] << endl;
    }

    output_file.close();

    cudaFree(d_n);
    cudaFree(d_change);

    return 0;
}
