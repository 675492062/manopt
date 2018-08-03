function using_gpu()
% Manopt example on how to use GPU with manifold factories that allow it.
%
% We are still working on this feature, and so far only few factories have
% been adapted to work on GPU. But the adaptations are rather easy. If
% there is a manifold you'd like to use on GPU, let us know via the forum
% on http://www.manopt.org, we'll be happy to help!
%
% See also: spherefactory stiefelfactory complexcirclefactory

% This file is part of Manopt: www.manopt.org.
% Original author: Nicolas Boumal, Aug. 3, 2018.
% Contributors: 
% Change log: 

    % Construct a large problem to illustrate the use of GPU.
    % Below, we will compute p left-most eigenvectors of A (symmetric).
    % On a particular test computer, we found that for n = 100, 1000, CPU
    % is faster, but for n = 10000, GPU tends to be 10x faster.
    p = 3;
    n = 10000;
    A = randn(n);
    A = A+A';
    
    inner = @(U, V) U(:)'*V(:);
    
    % First, setup and run the optimization problem on the CPU.
    problem.M = stiefelfactory(n, p, 1);  % 1 copy of Stiefel(n, p)
    problem.cost = @(X) .5*inner(X, A*X); % Rayleigh quotient to be minimized
    problem.egrad = @(X) A*X;             % Could use caching to save here
    X0 = problem.M.rand();                % Random initial guess
    tic_cpu = tic();
    X_cpu = trustregions(problem, X0); % run any solver
    time_cpu = toc(tic_cpu);
    
    % Then, move the data to the GPU, redefine the problem using the moved
    % data, activate the GPU flag in the factory, and run it again.
    A = gpuArray(A);
    problem.M = stiefelfactory(n, p, 1, true); % true is the GPU flag;
    problem.cost = @(X) .5*inner(X, A*X);      % Code for cost and gradient
    problem.egrad = @(X) A*X;                  % basically didn't change, but
    X0 = gpuArray(X0);                         % operates on gpuArrays now.
    tic_gpu = tic();
    X_gpu = trustregions(problem, X0);
    time_gpu = toc(tic_gpu);
    
    fprintf('Total time CPU: %g\nTotal time GPU: %g\nSolution difference: %g\n', ...
            time_cpu, time_gpu, norm(X_cpu - X_gpu, 'fro'));
    
end