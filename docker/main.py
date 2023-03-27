import numpy as np

# Element properties
E = 2e11 # Young's modulus
L = 1.0 # length of beam
A = 0.01 # cross-sectional area

# Boundary conditions
F = -1e5 # load at end of beam

# Discretization
N_elements = 10
N_nodes = N_elements + 1
dx = L/N_elements

# Global stiffness matrix and load vector
K = np.zeros((N_nodes, N_nodes))
f = np.zeros(N_nodes)

# Assemble element contributions
for i in range(N_elements):
    k = np.array([[1, -1], [-1, 1]]) * (E*A/dx)
    f[i] += dx*F/2
    f[i+1] += dx*F/2
    K[i:i+2, i:i+2] += k

# Apply boundary conditions
K = K[1:, 1:]
f = f[1:]

# Solve for nodal displacements
u = np.linalg.solve(K, f)

# Compute nodal reactions
R = np.zeros(N_nodes)
R[0] = -F
R[1:] = np.dot(K, u)

# Print results
print("Nodal displacements:", u)
print("Nodal reactions:", R)


with open('output.txt', 'w') as f:
    f.write(repr(u)+"\n"+repr(R))
