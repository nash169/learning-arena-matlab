%% Draw demos
clear; close all; clc;
gen_options.limits = [0 100 0 100];
gen_options.calc_vel = false;
gen_options.get_time = false;
gen_options.get_labels = true;
[demo, demo_struct] = GenerateDemos(gen_options);
close;
DataStruct.demo = demo;
DataStruct.demo_struct = demo_struct;
save('demos/CurrentTest.mat', 'DataStruct');