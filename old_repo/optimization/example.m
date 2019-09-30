function [sol, lambda] = example()
f = @(x) obj(x);
c1 = @(x) cstr1(x);
c2 = @(x) cstr2(x);

options_optim = optimoptions('fmincon',...
                             'SpecifyObjectiveGradient',true,...
                             'SpecifyConstraintGradient',true);
                         
x0 = rand(2,1);
[sol,~,~,~,lambda] = fmincon(@(x) combine_objectives(x, f),x0,[],[],[],[],[],[],...
                                    @(x) combine_constraints(x, c1, c2), options_optim);

end

function [f, g] = obj(x)
    f = (x(1)-2)^2 + 2*(x(2)-1)^2;
    if nargout > 1
        g = [2*(x(1)-2); 4*(x(2)-1)];
    end
end

function [c, ceq, DC, DCeq] = cstr1(x)
    c = x(1) + 4*x(2) - 3;
    ceq = [];
    
    if nargout > 2
        DC = [1; 4];
        DCeq = [];
    end
end

function [c, ceq, DC, DCeq] = cstr2(x)
    c = x(2) - x(1);
    ceq = [];
    
    if nargout > 2
        DC = [-1; 1];
        DCeq = [];
    end
end