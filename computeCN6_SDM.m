function [pos,test_CN6] = computeCN6_SDM(pose,options_T,CN6_R,CN6_b)
% CN_6 regression. requare to call the train parameters CN3_R and CN3_b.
         alpha = 0.1;
         gr6=[1 2 3 5 6 8;1 2 3 5 6 7;1 2 3 4 6 8;1 2 3 4 6 7;1 2 3 4 5 8;1 2 3 4 5 7]';
         test_CN6 = zeros(size(gr6,2),options_T);   
         for iter = 1:options_T
              test_CN6(:,iter) = cat(1,LDYsixcharnumber(pose(gr6(:,1),:)),...
                             LDYsixcharnumber(pose(gr6(:,2),:)),...
                             LDYsixcharnumber(pose(gr6(:,3),:)),...
                             LDYsixcharnumber(pose(gr6(:,4),:)),...
                             LDYsixcharnumber(pose(gr6(:,5),:)),...
                             LDYsixcharnumber(pose(gr6(:,6),:)));
             test6_step_deltx = (-CN6_R(:,:,iter)*test_CN6(:,iter) + CN6_b(:,:,iter))*alpha;

               if  max(abs(test6_step_deltx))>5     
                 test6_step_deltx = zeros(size(test6_step_deltx,1),size(test6_step_deltx,2));
               end
           for j = 1:size(gr6,2)
               BK = cat(2,test6_step_deltx(1:2:size(test6_step_deltx,1)),test6_step_deltx(2:2:size(test6_step_deltx,1))); 
               pose(gr6(:,j),:) = pose(gr6(:,j),:) + BK(1+(j-1)*size(gr6,1):j*size(gr6,1),:);  
           end
        end
      pos = pose;
end



