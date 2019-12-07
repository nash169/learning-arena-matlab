function check(obj)
assert(obj.is_data_, "Data not present");

if ~obj.is_params_
    for i  = 1 : length(obj.params_list_)
       assert(isfield(obj.params_,obj.params_list_{i}), ...
           '"%s" parameter missing', obj.params_list_{i})
    end
    obj.is_params_ = true;
end

if ~obj.is_centroids_
    % Init of  centroids uniform between mean +- 2*stadard_deviation
    std_data = std(obj.data_);
    mean_data = mean(obj.data_);
    range = [(mean_data - 2*std_data)', (mean_data + 2*std_data)'];
    obj.centroids_ = (range(:,1) - range(:,2))'.*rand(obj.params_.cluster, obj.d_) + range(:,2)';
    obj.is_centroids_ = true;
    
    % Labels assigned to the first cluster at the beginning
    obj.labels_ = ones(obj.m_,1);
    
    % Init kernel expansion for soft k-means
    if obj.params_.soft
        obj.params_.kernel.set_data(obj.data_, obj.centroids_);
    end
end

end

