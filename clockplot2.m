function clockplot2(data)

%This funciton takes data from clockplot.m and displays it nicely.

%data = data(1:1000,:);

x = 1:length(data);

%figure,
%hold on

plot(x,data(:,8),'Color',[0 0 .5],'LineWidth',5);
hold on;
plot(x,data(:,1),'Color',[0 0.5 1],'LineWidth',5);
plot(x,data(:,3),'Color',[0 1 1],'LineWidth',5);
plot(x,data(:,4),'Color',[0 1 0],'LineWidth',5);
plot(x,data(:,5),'Color',[1 .9 0],'LineWidth',5);
plot(x,data(:,6),'Color',[1 0.4 0],'LineWidth',5);
plot(x,data(:,7),'Color',[0.8 0 0],'LineWidth',5);

hold off


