% names = {'x'; 'y'; 'z'};
% 
% model.A = sparse([1 2 3; 1 1 0]);
% model.obj = [1 1 2];
% model.rhs = [4; 1];
% model.sense = '<>';
% model.vtype = 'B';
% model.modelsense = 'max';
% model.varnames = names;
% 
% gurobi_write(model, 'mip1.lp');
% 
% params.outputflag = 0;
% 
% result = gurobi(model, params);
% 
% disp(result);
% 
% for v=1:length(names)
%     fprintf('%s %d\n', names{v}, result.x(v));
% end
% 
% fprintf('Obj: %e\n', result.objval);

% x = sdpvar(1,1);
% y = sdpvar(1,1);
% z = sdpvar(1,1);
% 
% obj = x + y + 2*z;
% constr = [1*x + 2*y + 3*z<=4, x + y >=1, -500<=x<=500, -500<=y<=500, -500<=z<=500];
% options = sdpsettings('verbose',0,'solver','gurobi');
% sol = optimize(constr, -obj, options)

% x = sdpvar(1,1);
% y = sdpvar(1,1);
% z = sdpvar(1,1);
% 
% obj = x + y + 2*z;
% constr = [1*x + 2*y + 3*z<=4, x + y >=1, -500<=x<=500, -500<=y<=500, -500<=z<=500];
% options = sdpsettings('verbose',0,'solver','gurobi');
% sol = optimize(constr, -obj, options)

% x = sdpvar(1,1);
% y = sdpvar(1,1);
% z = sdpvar(1,1);
% 
% obj = x + y + 2*z;
% constr = [1*x + 2*y + 3*z<=4, x + y >=1, -500<=x<=500, -500<=y<=500, -500<=z<=500];
% options = sdpsettings('verbose',0,'solver','gurobi');
% sol = optimize(constr, -obj, options)

x = [1 2 3 4 5 6]';
t = (0:0.02:2*pi)';
A = [sin(t) sin(2*t) sin(3*t) sin(4*t) sin(5*t) sin(6*t)];
e = (-4+8*rand(length(A),1));
y = A*x+e;

xhat = sdpvar(6,1);
sdpvar u v

F = [norm(y-A*xhat,2) <= u, norm(xhat,2) <= v];
options = sdpsettings('verbose',0,'solver','sedumi', 'debug', 1);
optimize(F,u + v, options)