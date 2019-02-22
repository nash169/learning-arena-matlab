function Q = CovCenter2(x, y, x_i)
%COVCETER Summary of this function goes here
%   Detailed explanation goes here
[m,d] = size(x_i);
% [n,~] = size(y);

X = repmat(x,size(y,1),1);
Y = repelem(y,size(x,1),1);

% x_c = repmat(x,size(x,1),1) - repelem(x,size(x,1),1);
% y_c = repmat(y,size(y,1),1) - repelem(y,size(y,1),1);
xc_i = repmat(x_i,size(x,1),1) - repelem(x,size(x_i,1),1);

T_x = squeeze(sum(reshape((repelem(xc_i,1,d).*repmat(xc_i,1,d))',d^2,m,[]),2))';

% T_x = squeeze(sum(reshape((repelem(x_c,1,d).*repmat(x_c,1,d))',d^2,m,[]),2))';
% T_y = squeeze(sum(reshape((repelem(y_c,1,d).*repmat(y_c,1,d))',d^2,n,[]),2))';

% T_x = [6266 6459 6459 6797];

% C = (BlkMatrix(repmat(T_x,size(T_y,1),1)) + BlkMatrix(repelem(T_y,size(T_x,1),1)))/2;
C = BlkMatrix(repmat(T_x,size(y,1),1));

Q = sum((X-Y).*reshape(C\reshape((X-Y)',[],1),size(x,2),[])',2);
end

