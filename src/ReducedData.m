function demo = ReducedData(demo,num_points)

if num_points < 2
    error('What the fucking are you doing?');
end

for k  = 1:size(demo,1)
    demo_temp = zeros(size(demo{k},1), num_points);
    n = round(size(demo{k},2)/(num_points-1));
    if num_points > 2
       for i = 2:num_points-1
           demo_temp(:,i) = demo{k}(:,(i-1)*n);
       end 
    end
    demo_temp(:,1) = demo{k}(:,1);
    demo_temp(:,end) = demo{k}(:,end);
    demo{k} = demo_temp;
end

end