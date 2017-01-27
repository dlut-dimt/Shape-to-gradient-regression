% test function "explicit shape regression with characteristic number for facial landmark location"
% this function is to optimize charcteristic number(CN) by learning method, R and b are trained by training function 
% to run the code, you requare a initialization for the shape
%% load test Data
% function [] = TestCNSDM()

% maximum interations  
options.T = 10; 

% shape regression cycle times 
options.K = 1;     
flag_lfpw = [40 37 49 36 55 32 43 46];

% CN_i combinations.
gr3 = [1 7 8;1 2 7;1 2 8;2 7 8]';
gr5 = [4 2 8 1 3;1 2 7 4 6;2 1 8 4 6;7 8 2 3 5]';
gr6 = [1 2 3 5 6 8;1 2 3 5 6 7;1 2 3 4 6 8;1 2 3 4 6 7;1 2 3 4 5 8;1 2 3 4 5 7]';

test_TOTAL = 1; % 
Test_number = test_TOTAL; 

 %% shape regression
 
 Testdata = struct;  
for i = 1:test_TOTAL  
    
    % here, requare a load initial shape
    
         
for kkt = 1:options.K   
    % CN_3 regression.
    [res,test_CN3] = computeCN3_SDM(res,options.T,CN3_R,CN3_b);
    tests_CN3(:,(kkt-1)*options.T + 1:(kkt-1)*options.T + options.T,i) = test_CN3; 

   % CN_5 regression.
    [res,test_CN5] = computeCN5_SDM(res,options.T,CN5_R,CN5_b);
    tests_CN5(:,(kkt-1)*options.T + 1:(kkt-1)*options.T + options.T,i) = test_CN5;

   % CN_6 regression.
    [res,test_CN6] = computeCN6_SDM(res,options.T,CN6_R,CN6_b);
    tests_CN6(:,(kkt-1)*options.T + 1:(kkt-1)*options.T + options.T,i) = test_CN6;

end
    Testdata(i).FPoint = res; 
    disp(sprintf('error after regression:%f', mean(sum((Testdata(i).FPoint - groundtruth_test_lfpw(i).FPoint(flag_lfpw,:)).^2, 2))))
    disp(sprintf('error before regression:%f',mean(sum((initial_shape(:,:,i) - groundtruth_test_lfpw(i).FPoint(flag_lfpw,:)).^2, 2))))
    disp ''
end



















 



