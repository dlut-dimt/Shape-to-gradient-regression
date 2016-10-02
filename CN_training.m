% training function "explicit shape regression with characteristic number for facial landmark location"
% we augment the training data by randomly sampling multiple candidates for each image.
% this function is to optimize charcteristic number(CN) constraint by learning regression method. 
%% initilization global parameter  
% perturbed samples for each training image
options.k = 20;  
% maximum iteration
options.T = 10;

%% load training data                                              
load('dataset\traing_set\groundtruth_train_lfpw.mat');
flag_lfpw = [40 37 49 36 55 32 43 46];
Training_Data = struct; 

for i = 1:size(groundtruth_train_lfpw,2)                                                        
    Training_Data(i).FPoint = groundtruth_train_lfpw(i).FPoint(flag_lfpw,:);   
    img = imread(['dataset\traing_set\',num2str(i),'.png']);
    Training_Data(i).I = img;   
end 

%% Training - initialize 
TOTAL_SIZE = size(Training_Data,2)*options.k;  % each trainingset contains 10 perturbed sample numbers.
options.fp = size(Training_Data(1).FPoint,1); % each face contains options.fp points.

% CN_i combinations.
gr3 = [1 7 8;1 2 7;1 2 8;2 7 8]';
gr5 = [4 2 8 1 3;1 2 7 4 6;2 1 8 4 6;7 8 2 3 5]';
gr6=[1 2 3 5 6 8;1 2 3 5 6 7;1 2 3 4 6 8;1 2 3 4 6 7;1 2 3 4 5 8;1 2 3 4 5 7]';

% format:[ point_id,[x,y],Training_Data_id];
groundtruth_shape = zeros(options.fp,2,TOTAL_SIZE);
es_shape = zeros(options.fp,2,TOTAL_SIZE);
for j = 1:TOTAL_SIZE
     groundtruth_shape(:,:,j) = Training_Data(ceil(j/options.k)).FPoint;
end

initial_shape =  zeros(size(Training_Data(1).FPoint,1),2,TOTAL_SIZE);
initial_shape = groundtruth_shape + (6-12*rand(size(Training_Data(1).FPoint,1),2,TOTAL_SIZE));  


% Initialize the estimate shape
estimate_shapes = initial_shape;

groundtruth_CN3 = zeros(1,size(gr3,2),TOTAL_SIZE);
groundtruth_CN5 = zeros(1,size(gr5,2),TOTAL_SIZE);
groundtruth_CN6 = zeros(1,size(gr6,2),TOTAL_SIZE);

% percompute groundtruth intrinsic values include CN_3,CN_5,CN_6. 
for i = 1:TOTAL_SIZE
    groundtruth_CN3(:,:,i) = cat(1,charnumber3(groundtruth_shape(gr3(:,1),:,i)),...
                            charnumber3(groundtruth_shape(gr3(:,2),:,i)),...
                            charnumber3(groundtruth_shape(gr3(:,3),:,i)),...
                            charnumber3(groundtruth_shape(gr3(:,4),:,i)));

   groundtruth_CN5(:,:,i) = cat(1,fivePointCN(groundtruth_shape(gr5(:,1),:,i)),...
                            fivePointCN(groundtruth_shape(gr5(:,2),:,i)),...
                            fivePointCN(groundtruth_shape(gr5(:,3),:,i)),...
                            fivePointCN(groundtruth_shape(gr5(:,4),:,i)));  

    groundtruth_CN6(:,:,i) = cat(1,LDYsixcharnumber(groundtruth_shape(gr6(:,1),:,i)),...
                            LDYsixcharnumber(groundtruth_shape(gr6(:,2),:,i)),...
                            LDYsixcharnumber(groundtruth_shape(gr6(:,3),:,i)),...
                            LDYsixcharnumber(groundtruth_shape(gr6(:,4),:,i)),...
                            LDYsixcharnumber(groundtruth_shape(gr6(:,5),:,i)),...
                            LDYsixcharnumber(groundtruth_shape(gr6(:,6),:,i)));
end

% CN_3 parameter initialize.                    
    estimated_CN3 = zeros(options.T,size(gr3,2),TOTAL_SIZE);
    sum_CN3 = zeros(size(gr3,2),1);
    sum3_deltx = zeros(size(gr3,2)*size(gr3,1)*2,1);
    sum_deltxbytrCN3 = zeros(size(gr3,2)*size(gr3,1)*2,size(gr3,2));
    CN3_R = zeros(size(gr3,2)*size(gr3,1)*2,size(gr3,2),options.T);
    CN3_b = zeros(size(gr3,2)*size(gr3,1)*2,1,options.T);
    sum_CN3bytrCN3 = zeros(size(gr3,2),size(gr3,2));
    
% CN_5 pamameter initalize.
    estimated_CN5 = zeros(options.T,size(gr5,2),TOTAL_SIZE);
    sum_CN5 = zeros(size(gr5,2),1);
    sum5_deltx = zeros(size(gr5,2)*size(gr5,1)*2,1);
    sum_deltxbytrCN5 = zeros(size(gr5,2)*size(gr5,1)*2,size(gr5,2));
    CN5_R = zeros(size(gr5,2)*size(gr5,1)*2,size(gr5,2),options.T);
    CN5_b = zeros(size(gr5,2)*size(gr5,1)*2,1,options.T);
    sum_CN5bytrCN5 = zeros(size(gr5,2),size(gr5,2));
    
% CN_6 pamameter initialize.
    estimated_CN6 = zeros(options.T,size(gr6,2),TOTAL_SIZE);
    sum_CN6 = zeros(size(gr6,2),1);
    sum6_deltx = zeros(size(gr6,2)*size(gr6,1)*2,1);
    sum_deltxbytrCN6 = zeros(size(gr6,2)*size(gr6,1)*2,size(gr6,2));
    CN6_R = zeros(size(gr6,2)*size(gr6,1)*2,size(gr6,2),options.T);
    CN6_b = zeros(size(gr6,2)*size(gr6,1)*2,1,options.T);
    sum_CN6bytrCN6 = zeros(size(gr6,2),size(gr6,2));

%% Training - Running
% CN_3 regression. 
for iter = 1:options.T
    pose = zeros(options.fp,2);  % shape initial 
    sum_CN3 = zeros(size(gr3,2),1);% all CN values sum. 
    sum3_deltx = zeros(size(gr3,2)*size(gr3,1)*2,1); % sum values of trainging set errors
    sum_deltxbytrCN3 = zeros(size(gr3,2)*size(gr3,1)*2,size(gr3,2));  % sum values of deltx by CN3(transpose)
    sum_CN3bytrCN3 = zeros(size(gr3,2),size(gr3,2)); % sum values of square CN values.
    for i = 1:TOTAL_SIZE
        pose = estimate_shapes(:,:,i);% 
        deltx = zeros(size(gr3,2)*size(gr3,1)*2,1);
        estimated_CN3(iter,:,i) = cat(1,charnumber3(pose(gr3(:,1),:)),...
                                     charnumber3(pose(gr3(:,2),:)),...
                                     charnumber3(pose(gr3(:,3),:)),...
                                     charnumber3(pose(gr3(:,4),:)));                        
        sum_CN3 = sum_CN3 + estimated_CN3(iter,:,i)';
        deltx = reshape(groundtruth_shape(gr3(:),:,i)',[size(gr3,1)*size(gr3,2)*2,1])  - reshape(pose(gr3(:),:)',[size(gr3,1)*size(gr3,2)*2,1]);
        sum3_deltx = sum3_deltx + deltx;
        sum_deltxbytrCN3 = sum_deltxbytrCN3 + deltx*estimated_CN3(iter,:,i); 
        sum_CN3bytrCN3 = sum_CN3bytrCN3 + estimated_CN3(iter,:,i)'*estimated_CN3(iter,:,i);
    end
    
   % optimize to solve R and b.
   
    CN3_R(:,:,iter) = (sum3_deltx*sum_CN3'/TOTAL_SIZE-sum_deltxbytrCN3)*inv(sum_CN3bytrCN3-sum_CN3*sum_CN3'/TOTAL_SIZE);
    CN3_b(:,:,iter) = CN3_R(:,:,iter)*sum_CN3/TOTAL_SIZE + sum3_deltx/TOTAL_SIZE;
    step_deltx = zeros(size(gr3,2)*size(gr3,1)*2,1);
   % transform regression vector into regression matrix.
   
    for i = 1:TOTAL_SIZE
        step_deltx = (-CN3_R(:,:,iter)*estimated_CN3(iter,:,i)' + CN3_b(:,:,iter))*0.1; 
       for j = 1:size(gr3,2)
           B = cat(2,step_deltx(1:2:size(step_deltx,1)),step_deltx(2:2:size(step_deltx,1))); 
           estimate_shapes(gr3(:,j),:,i) = estimate_shapes(gr3(:,j),:,i) + B(1+(j-1)*size(gr3,1):j*size(gr3,1),:);  
       end
    end
end

% CN_5 regression
for iter = 1:options.T
    pose = zeros(options.fp,2);  % shape initial 
    sum_CN5 = zeros(size(gr5,2),1);% all CN values sum. 
    sum5_deltx = zeros(size(gr5,2)*size(gr5,1)*2,1); % sum values of trainging set errors.
    sum_deltxbytrCN5 = zeros(size(gr5,2)*size(gr5,1)*2,size(gr5,2));  % sum values of deltx by CN3(transpose).
    sum_CN5bytrCN5 = zeros(size(gr5,2),size(gr5,2)); % sum values of square CN values. 
    for i = 1:TOTAL_SIZE
        pose = estimate_shapes(:,:,i);% 
        deltx = zeros(size(gr5,2)*size(gr5,1)*2,1);

        estimated_CN5(iter,:,i) = cat(1, fivePointCN(pose(gr5(:,1),:)),...
                                         fivePointCN(pose(gr5(:,2),:)),...
                                         fivePointCN(pose(gr5(:,3),:)),...
                                         fivePointCN(pose(gr5(:,4),:)));  
                                    
        sum_CN5 = sum_CN5 + estimated_CN5(iter,:,i)';
        deltx = reshape(groundtruth_shape(gr5(:),:,i)',[size(gr5,1)*size(gr5,2)*2,1])  - reshape(pose(gr5(:),:)',[size(gr5,1)*size(gr5,2)*2,1]);
        sum5_deltx = sum5_deltx + deltx;
        sum_deltxbytrCN5 = sum_deltxbytrCN5 + deltx*estimated_CN5(iter,:,i); 
        sum_CN5bytrCN5 = sum_CN5bytrCN5 + estimated_CN5(iter,:,i)'*estimated_CN5(iter,:,i);
    end
% optimize to solve R and b.
    CN5_R(:,:,iter) = (sum5_deltx*sum_CN5'/TOTAL_SIZE-sum_deltxbytrCN5)*inv(sum_CN5bytrCN5-sum_CN5*sum_CN5'/TOTAL_SIZE);
    CN5_b(:,:,iter) = CN5_R(:,:,iter)*sum_CN5/TOTAL_SIZE + sum5_deltx/TOTAL_SIZE;
    step_deltx = zeros(size(gr5,2)*size(gr5,1)*2,1);
    
% transform regression vector into regression matrix.
    for i = 1:TOTAL_SIZE
         step_deltx = (-CN5_R(:,:,iter)*estimated_CN5(iter,:,i)' + CN5_b(:,:,iter))*0.1; 
       for j = 1:size(gr3,2)
           B = cat(2,step_deltx(1:2:size(step_deltx,1)),step_deltx(2:2:size(step_deltx,1))); 
           estimate_shapes(gr5(:,j),:,i) = estimate_shapes(gr5(:,j),:,i) + B(1+(j-1)*size(gr5,1):j*size(gr5,1),:);  
       end
    end
end

% CN_6 regression
for iter = 1:options.T
    pose = zeros(options.fp,2);  % shape initial 
    sum_CN6 = zeros(size(gr6,2),1);% all CN values sum. 
    sum6_deltx = zeros(size(gr6,2)*size(gr6,1)*2,1); % sum values of trainging set errors
    sum_deltxbytrCN6 = zeros(size(gr6,2)*size(gr6,1)*2,size(gr6,2));  % sum values of deltx by CN3(transpose)
    sum_CN6bytrCN6 = zeros(size(gr6,2),size(gr6,2)); % sum values of square CN values.
    for i = 1:TOTAL_SIZE
        pose = estimate_shapes(:,:,i);% 
        deltx = zeros(size(gr6,2)*size(gr6,1)*2,1);
        estimated_CN6(iter,:,i) = cat(1,LDYsixcharnumber(pose(gr6(:,1),:)),...
                                        LDYsixcharnumber(pose(gr6(:,2),:)),...
                                        LDYsixcharnumber(pose(gr6(:,3),:)),...
                                        LDYsixcharnumber(pose(gr6(:,4),:)),...
                                        LDYsixcharnumber(pose(gr6(:,5),:)),...
                                        LDYsixcharnumber(pose(gr6(:,6),:)));                     
        sum_CN6 = sum_CN6 + estimated_CN6(iter,:,i)';
        deltx = reshape(groundtruth_shape(gr6(:),:,i)',[size(gr6,1)*size(gr6,2)*2,1])  - reshape(pose(gr6(:),:)',[size(gr6,1)*size(gr6,2)*2,1]);
        sum6_deltx = sum6_deltx + deltx;
        sum_deltxbytrCN6 = sum_deltxbytrCN6 + deltx*estimated_CN6(iter,:,i); 
        sum_CN6bytrCN6 = sum_CN6bytrCN6 + estimated_CN6(iter,:,i)'*estimated_CN6(iter,:,i);
    end
    
   % optimize to solve R and b.
    CN6_R(:,:,iter) = (sum6_deltx*sum_CN6'/TOTAL_SIZE-sum_deltxbytrCN6)*inv(sum_CN6bytrCN6-sum_CN6*sum_CN6'/TOTAL_SIZE);
    CN6_b(:,:,iter) = CN6_R(:,:,iter)*sum_CN6/TOTAL_SIZE + sum6_deltx/TOTAL_SIZE;
    step_deltx = zeros(size(gr6,2)*size(gr6,1)*2,1);
   % transform regression vector into regression matrix.
    for i = 1:TOTAL_SIZE
        step_deltx = (-CN6_R(:,:,iter)*estimated_CN6(iter,:,i)' + CN6_b(:,:,iter))*0.1;   
       for j = 1:size(gr6,2)
           B = cat(2,step_deltx(1:2:size(step_deltx,1)),step_deltx(2:2:size(step_deltx,1))); 
           estimate_shapes(gr6(:,j),:,i) = estimate_shapes(gr6(:,j),:,i) + B(1+(j-1)*size(gr6,1):j*size(gr6,1),:);  
       end
    end
end




