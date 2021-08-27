clf;
% automatically create postscript whenever
% figure is drawn
tmpfilename = 'figReff_sens1_early';
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

% main data goes here
clear stats
clear prs
pars.eta=1/2;    % Transition to symptoms
pars.gamma=1/7; % Resolution rate
pars.beta=2/7; % Hazard
pars.sens=0.75;
pars.R0=1.2:0.1:2.5;
pars.freq_testing=3:1:10;

for i=1:length(pars.R0),
  for j=1:length(pars.freq_testing),
    pars.beta=pars.R0(i)*pars.gamma;
    pars.tau=pars.freq_testing(j);
    N=1.5*10^4;
    y0 = [0.99 0.005 0.005*(1-pars.sens) 0.005*pars.sens];
    opts=odeset('reltol',1e-10);
    [t,y]=ode45(@seir_model,[0 200], y0,opts,pars);
    stats.outbreak(i,j)=1-y(end,1);
  end
end
%imagesc(pars.R0,pars.freq_testing,stats.outbreak*N);
%hold on
[R0vec testvec]=meshgrid(pars.R0,pars.freq_testing);
[c,h]=contour(R0vec',testvec',stats.outbreak*N,[100:50:500 750 1000:1000:10000]);
clabel(c,h)
set(h,'linewidth',2);
set(gca,'ydir','normal');
set(gca,'xtick',[1.25:0.25:2.5]);
caxis([0 10000]);
%hold on
%pars.R0range=1.1:0.01:2.5;
%tcrit = pars.sens/pars.gamma./(pars.R0range-1);
%tmph=plot(pars.R0range,tcrit,'w-');
%set(tmph,'linewidth',3);
%tmps=contour(R0vec',testvec',stats.outbreak*N);
%semilogy(t,y);
%legend('S','E','I1','I2','R','D');
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

xlabel('Baseline, ${\cal{R}}_0$','fontsize',18,'verticalalignment','top','interpreter','latex');
ylabel('Testing frequency, days','fontsize',18,'verticalalignment','bottom','interpreter','latex');
 title({'Outbreak size, 15,000 students, 75\% sensitivity';'including entry testing'},'fontsize',18,'interpreter','latex')
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
