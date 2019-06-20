function B = Orthogonalize(v)
%OTHOGONALIZE Summary of this function goes here
%   Detailed explanation goes here

d = length(v);
B = rand(length(v));
B(:,1) = v/norm(v);

% for i = 2:d
%     for j = 1:i
%        B(:,i) = B(:,i) - B(:,j)'*B(:,i).*B(:,j);
%     end
%     B(:,i) = B(:,i)/norm(B(:,i));
% end

for i = 2:d
    B(:,i) = B(:,i) - sum(repmat(B(:,i)'*B(:,1:i-1),d,1).*B(:,1:i-1),2);
    B(:,i) = B(:,i)/norm(B(:,i));
end


end

