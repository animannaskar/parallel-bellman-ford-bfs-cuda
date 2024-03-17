<body>
    <header style="background-color: #4CAF50; color: white; padding: 10px 0; text-align: center;">
        <h1 style="font-size: 20px; margin-bottom: 20px;">Parallel implementation of Bellman Ford on GPUs using CUDA</h1>
    </header>
    <p style="text-align: justify; padding: 20px;">
    This project features a parallel implementation of Bellman Ford algorithm on NVIDIA GPUs using CUDA (Compute Unified Device Architecture). 
    </p>
    <div style="font-family: Arial, sans-serif; font-size: 16px; line-height: 1.5; text-align: justify; padding: 20px;">
        <p><strong>Parallel Bellman-Ford algorithm proceeds as follows:</strong></p>
        <p><strong>Initialize Distance Array:</strong> Start by initializing the distance array, where the distance from the source node is set to 0 and all other distances are set to infinity.</p>
        <p><strong>Iterative Process:</strong></p>
        <ul style="list-style-type: disc; margin-left: 20px;">
          <li><strong>Parallel Edge Relaxation:</strong>Parallelly inspect each vertex and, when feasible, decrease the distance to its neighboring vertices through its outgoing edges</li>
            <li><strong>Check for Changes:</strong> After each iteration, check if any distance reductions were made. If so, set a boolean flag "change" to 1.</li>
            <li><strong>Repeat Iteration:</strong> Continue iterating while "change" is 1, indicating that there are still distance reductions to be made.</li>
        </ul>
        <p>By following these steps, the Parallel Bellman-Ford algorithm efficiently computes shortest paths in the graph by reducing distances in parallel and updating the distance array until no further changes are possible.</p>
    </div>
    <p>
    <b>Benchmarking results</b>
    <br><br>
    <img src = "https://github.com/animannaskar/parallel-bellman-ford-on-gpu/assets/143376315/e7929ffa-f53e-4e35-b945-8a699a5f553a">
    </p>
</body>
