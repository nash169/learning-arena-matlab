function [x_dot, x_next] = SampleDS(f, x_0, dt, T)

% Create storage vectors in order to accept different formats
if size(x_0,1) == 1
    x_dot = zeros(T/dt,length(x_0));
    x_next = x_dot;

    x_dot(1,:) = f(x_0);
    x_next(1,:) = x_0;

    for i = 2:T/dt+1
        x_next(i,:) = x_next(i-1,:) + dt*x_dot(i-1,:);
        x_dot(i,:) = f(x_next(i,:));
    end
else
    x_dot = zeros(length(x_0),T/dt);
    x_next = x_dot;

    x_dot(:,1) = f(x_0);
    x_next(:,1) = x_0;

    for i = 2:T/dt+1
        x_next(:,i) = x_next(:,i-1) + dt*x_dot(:,i-1);
        x_dot(:,i) = f(x_next(:,i));
    end
end

end
