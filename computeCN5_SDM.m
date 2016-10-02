function [pos,test_CN5] = computeCN5_SDM(pose,options_T,CN5_R,CN5_b)
% CN_3 regression. requare to call the train parameters CN3_R and CN3_b.
          alpha = 0.1;
      gr5 = [4 2 8 1 3;1 2 7 4 6;2 1 8 4 6;7 8 2 3 5]';
      test_CN5 = zeros(size(gr5,2),options_T);  
       for iter = 1:options_T
            test_CN5(:,iter) =  cat(1, fivePointCN(pose(gr5(:,1),:)),...
                                         fivePointCN(pose(gr5(:,2),:)),...
                                         fivePointCN(pose(gr5(:,3),:)),...
                                         fivePointCN(pose(gr5(:,4),:)));  

             test5_step_deltx = (-CN5_R(:,:,iter)*test_CN5(:,iter) + CN5_b(:,:,iter))*alpha;  
              if  max(abs(test5_step_deltx))>5   
                  test5_step_deltx = zeros(size(test5_step_deltx,1),size(test5_step_deltx,2));
              end
        for j = 1:size(gr5,2)
            BK = cat(2,test5_step_deltx(1:2:size(test5_step_deltx,1)),test5_step_deltx(2:2:size(test5_step_deltx,1))); 
            pose(gr5(:,j),:) = pose(gr5(:,j),:) + BK(1+(j-1)*size(gr5,1):j*size(gr5,1),:);  
        end
      end
      pos = pose;
end
























