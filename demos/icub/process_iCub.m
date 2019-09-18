clear; close all; clc;

X_joints = [];
V_joints = [];
X_obj = [];
V_obj = [];

dynamics = 2;
trajs = 3;

demo_joints = cell(dynamics,1);
demo_obj_pos = cell(dynamics,1);
demo_obj_rot = cell(dynamics,1);

for i=1:trajs
   S = load(strcat('ds',num2str(dynamics),'_traj',num2str(i),'.txt'));
   
   t = S(:,1);
   S(:,1) = [];
   S_dev = [(S(2:end,:) - S(1:end-1,:))./(t(2:end) - t(1:end-1)); zeros(1,size(S,2))];
   
   demo_joints{i,1} = [S(:,1:end-6)'; S_dev(:,1:end-6)'; t'-t(1); dynamics*ones(1,length(t))];
   demo_obj_pos{i,1} = [S(:,end-5:end-3)'; S_dev(:,end-5:end-3)'; t'-t(1); dynamics*ones(1,length(t))];
   demo_obj_rot{i,1} = [S(:,end-2:end)'; S_dev(:,end-2:end)'; t'-t(1); dynamics*ones(1,length(t))];
end

demo_struct = {'position','velocity','time','labels'};
save(strcat('iCub_dyn',num2str(dynamics)),'demo_joints','demo_obj_pos','demo_obj_rot','demo_struct');
