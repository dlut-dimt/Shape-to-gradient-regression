function LDYsixcharnumber=LDYsixcharnumber(p)
% function to calculate value of CN_6 
p(:,end+1)=[1;1;1;1;1;1];
A=det([p(1,:);p(3,:);p(6,:)]);
B=det([p(1,:);p(2,:);p(4,:)]);
C=det([p(2,:);p(3,:);p(5,:)]);
D=det([p(2,:);p(3,:);p(6,:)]);
E=det([p(1,:);p(3,:);p(4,:)]);
F=det([p(1,:);p(2,:);p(5,:)]);
x=A*B*C;
y=D*E*F;
LDYsixcharnumber=x/y;
end





