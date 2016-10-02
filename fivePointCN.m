function FivePointCN_value = fivePointCN(p)
% function to calculate value of CN_5 
p(:,end+1) = [1;1;1;1;1];
A1 = det([p(1,:);p(3,:);p(5,:)]);         
B1 = det([p(1,:);p(4,:);p(5,:)]);
C1 = det([p(2,:);p(4,:);p(5,:)]);
D1 = det([p(2,:);p(3,:);p(5,:)]);
A2 = det([p(2,:);p(3,:);p(4,:)]);
B2 = det([p(1,:);p(3,:);p(4,:)]);
C2 = det([p(1,:);p(4,:);p(5,:)]);
D2 = det([p(2,:);p(4,:);p(5,:)]);
FivePointCN_value = (1-A1/B1*C1/D1)./(A2/B2*C2/D2-1);
end