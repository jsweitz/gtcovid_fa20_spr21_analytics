clf;
% automatically create postscript whenever
% figure is drawn
tmpfilename = 'figreshall';
tmpfilebwname = sprintf('%s_noname_bw',tmpfilename);
tmpfilenoname = sprintf('%s_noname',tmpfilename);

tmpprintname = fixunderbar(tmpfilename);
% for use with xfig and pstex
tmpxfigfilename = sprintf('x%s',tmpfilename);

tmppos= [0.2 0.2 0.7 0.7];
tmpa1 = axes('position',tmppos);

set(gcf,'DefaultLineMarkerSize',10);
% set(gcf,'DefaultLineMarkerEdgeColor','k');
% set(gcf,'DefaultLineMarkerFaceColor','w');
set(gcf,'DefaultAxesLineWidth',2);

set(gcf,'PaperPositionMode','auto');
set(gcf,'Position',[744 467 851 483]);

% main data goes here
[num,txt,raw]=xlsread('test_residence_cases.xlsx');
dtest = datetime(num(:,1),'convertfrom','excel');
tmph=bar(dtest,num(:,2));
set(gca,'xtick',dtest([1:10:91]));
set(gca,'xticklabelrotation',-30);
set(gca,'xminortick','on');
set(gca,'ytick',[0:30:150]);
hold on
% Plot positives
tmpi=find(num(:,3)>0);
tmph=plot(dtest(tmpi),num(tmpi,3)*30,'ro'); % Scale to fit on axis
set(tmph,'markersize',10,'markerfacecolor','r');
tmpi=find(num(:,3)==0);
tmph=plot(dtest(tmpi),num(tmpi,3),'ro');
set(tmph,'markersize',8);
% Label the right-hand y axis
for i=0:5,
  tmpt=text(dtest(end)+3,i*30,sprintf('%d',i));
  set(tmpt,'fontsize',20,'color','r');
end
tmpt=text(dtest(end)+9,1.4*30,'Positive cases');
set(tmpt,'fontsize',20,'rotation',90,'color','r');

% Label
tmpt=text(dtest(end)-8,140,'(B)');
set(tmpt,'fontsize',20);



% loglog(,, '');
%
%
% Some helpful plot commands
% tmph=plot(x,y,'ko');
% set(tmph,'markersize',10,'markerfacecolor,'k');
% tmph=plot(x,y,'k-');
% set(tmph,'linewidth',2);

set(gca,'fontsize',20);

% for use with layered plots
% set(gca,'box','off')

% adjust limits
% tmpv = axis;
% axis([]);
% ylim([]);
% xlim([]);

% change axis line width (default is 0.5)
% set(tmpa1,'linewidth',2)

% fix up tickmarks
% set(gca,'xtick',[1 100 10^4])
% set(gca,'ytick',[1 100 10^4])

% creation of postscript for papers
% psprint(tmpxfigfilename);

% the following will usually not be printed 
% in good copy for papers
% (except for legend without labels)

% legend
% tmplh = legend('stuff',...);
% tmplh = legend('','','');
% remove box
% set(tmplh,'visible','off')
% legend('boxoff');

xlabel('','fontsize',20,'verticalalignment','top','interpreter','latex');
ylabel('Number of tests','fontsize',20,'verticalalignment','bottom','interpreter','latex');
% title('','fontsize',24)
% 'horizontalalignment','left');

% for writing over the top
% coordinates are normalized again to (0,1.0)
tmpa2 = axes('Position', tmppos);
set(tmpa2,'visible','off');
% first two points are normalized x, y positions
% text(,,'','Fontsize',14);

% automatic creation of postscript
% without name/date
psprintc(tmpfilenoname);
psprint(tmpfilebwname);

tmpt = pwd;
tmpnamememo = sprintf('[source=%s/%s.ps]',tmpt,tmpprintname);
text(1.05,.05,tmpnamememo,'Fontsize',6,'rotation',90);
datenamer(1.1,.05,90);
% datename(.5,.05);
% datename2(.5,.05); % 2 rows

% automatic creation of postscript
psprintc(tmpfilename);

% set following on if zooming of 
% plots is required
% may need to get legend up as well
%axes(tmpa1)
%axes(tmplh)
clear tmp*
