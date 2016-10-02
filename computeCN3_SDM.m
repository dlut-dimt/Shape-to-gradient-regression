function [pos,test_CN3] = computeCN3_SDM(pose,options_T,CN3_R,CN3_b)
% CN_3 regression. requare to call the train parameters CN3_R and CN3_b.
         alpha = 0.1;
         gr3 = [1 7 8;1 2 7;1 2 8; 2 7 8]';
         test_CN3 = zeros(size(gr3,2),options_T);      
         for iter = 1:options_T
              test_CN3(:,iter) = cat(1,charnumber3(pose(gr3(:,1),:)),...
                                    charnumber3(pose(gr3(:,2),:)),...
                                    charnumber3(pose(gr3(:,3),:)),...
                                    charnumber3(pose(gr3(:,4),:)));
             test3_step_deltx = (-CN3_R(:,:,iter)*test_CN3(:,iter) + CN3_b(:,:,iter))*alpha;
             if  max(abs(test3_step_deltx))>5     
                 test3_step_deltx = zeros(size(test3_step_deltx,1),size(test3_step_deltx,2));
             end  
             for j = 1:size(gr3,2)
                 BK = cat(2,test3_step_deltx(1:2:size(test3_step_deltx,1)),test3_step_deltx(2:2:size(test3_step_deltx,1))); 
                 pose(gr3(:,j),:) = pose(gr3(:,j),:) + BK(1+(j-1)*size(gr3,1):j*size(gr3,1),:);  
             end
        end
      pos = pose;
end


