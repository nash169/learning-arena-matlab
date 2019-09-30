clear; close all; clc;

num_points = 2;

A = rand(num_points);
A = 0.5*(A+A') + eye(num_points)*num_points;
A = (A + A')/2 + eye(num_points)*1e-5;

B = rand(num_points);
B = 0.5*(B+B') + eye(num_points)*num_points;
B = (B+B')/2 + eye(num_points)*1e-5;

x0 = rand(num_points,1);

f1 = OptimObjectives('kpca', A);
f2 = OptimObjectives('kpca', B);
c1 = OptimConstraints('l2Ball');
c2 = OptimConstraints('l1Ball');

options_optim = optimoptions('fmincon','SpecifyObjectiveGradient',true, ...
                                       'SpecifyConstraintGradient', true, ...
                                       'MaxFunctionEvaluations',1e6);
                                   
sol = fmincon(@(x) CreateFunHanlde(x, f1, f2),x0,[],[],[],[],[],[],...
              @(x) CreateFunHanlde(x, c1,c2), options_optim);                                