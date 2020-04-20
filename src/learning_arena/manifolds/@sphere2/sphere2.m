classdef sphere2 < abstract_manifold
    %SPHERE Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = sphere2(varargin)
            %SPHERE Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_manifold(varargin{:});
        end

    end

    %=== PROTECTED ===%
    methods (Access = protected)
        signature(obj)

        f = calc_embedding(obj, data)

        x = calc_sampled(obj, num_points)
    end

end
