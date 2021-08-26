rm(list=ls())
### ABOUT ######################################################################
#
# Last Updated: 2021-08-20 CYZ
#
#   This script reads in an EXSUM file and generates a %-positive survey plot.
#
################################################################################

require(binom)
require(readxl)
require(scales)
require(ggplot2)
require(rDrop)
require(cowplot)


# --- INPUTS --------------------------------------------------------------
EXSUM_FILE_NAME = 'EXSUM_GT COVID Testing_TOTALS-FALL20_SPRING21.xlsx' #"EXSUM_GT COVID Testing_TOTALS-2021_02_03.xlsx"

# (0) Load Data -----------------------------------------------------------

EXSUM_PLOTNAME = paste(gsub('.xlsx', '', EXSUM_FILE_NAME), '_trendsPlot.png', sep='')
EXSUM_SPRING_PLOTNAME = paste(gsub('.xlsx', '', EXSUM_FILE_NAME), '_springTrendsPlot.png', sep='')
TODAYS_DATE = Sys.Date()

raw.in = read_xlsx(EXSUM_FILE_NAME)
df.in = data.frame(raw.in, stringsAsFactors = F)
df.in = df.in[order(df.in$Date, decreasing = T),]

# (1) Format Data ---------------------------------------------------------
# Goal: date; moving trend
df.in$Date = as.Date(df.in[[1]], format="%Y-%m-%d")

# Bin by date
ls.in = split(df.in, df.in$Date)
temp.in = lapply(ls.in, function(x){
  date = x$Date[1]
  session = x$Surv.Session
  if(length(session)>1){
    temp.session = sapply(session, function(y){
      gsub('Surveillance ', '', y)
    })
    session = paste('Surveillance '
                    , temp.session[1]
                    , '-'
                    , temp.session[length(temp.session)]
                    , sep='', collapse='')
  }
  total = sum(x$Total.Specimens) - sum(x$X..Invalid)
  total_rec = sum(x$X..Rec.Diagnostic.1)
  total_pos = sum(x$X..Positive)
  total_CLIA = sum(x$Total.CLIA)
  
  ret = data.frame('Date' = date
                   , 'Surv.Session' = session
                   , 'Total' = total
                   , 'Recommended' = total_rec
                   , 'CLIA' = total_CLIA
                   , 'Positive' = total_pos)
  return(ret)
})

df.survey = do.call('rbind', temp.in)
df.survey = df.survey[df.survey$Date < TODAYS_DATE,] #XXX 02.05.2021 hotfix

# Only include dates where CLIA is completed:
# - If CLIA == 0, check if date was within 2 days
b.test_complete = (df.survey$CLIA==0 & ((as.Date(TODAYS_DATE)-df.survey$Date)<=2))
df.survey = df.survey[!b.test_complete,]

# Only days where there are valid samples
df.survey = df.survey[df.survey$Total>0,]

# Handle dates separately
v.dates = df.survey$Date
v.dates_numeric = as.numeric(v.dates - v.dates[1])
df.survey$Date_numeric = v.dates_numeric

v.date_labels = format(v.dates, format = "%d %b")


# (2) Calculate Stats -----------------------------------------------------
# Positive %
df.survey$Pct.Pos = 100*df.survey$Positive/df.survey$Total

v.movingAvg = apply(df.survey, 1, function(x){
  date_num_end = as.numeric(x[which(colnames(df.survey)=='Date_numeric')])
  date_num_start = date_num_end-7
  
  b.window = df.survey$Date_numeric %in% date_num_start:date_num_end
  sliding.pos = sum(df.survey$Positive[b.window])
  sliding.tot = sum(df.survey$Total[b.window])
  
  return(sliding.pos/sliding.tot*100)
})

# Additional Stats
df.survey$MovingAvg = v.movingAvg

temp.bino = do.call('rbind', apply(df.survey[,c('Positive', 'Total')], 1
                                   , function(x){binom.bayes(x[1], x[2], conf.level=.8)}))
df.survey$lower = temp.bino$lower*100
df.survey$upper = temp.bino$upper*100


# (3) Plot Results --------------------------------------------------------
df.survey = df.survey[order(df.survey$Date, decreasing = T),]

# For plotting
ymax = ceiling(max(df.survey$upper))
df.survey$year = format(df.survey$Date, '%Y')

b.spring21 = (df.survey$Date>=as.Date('2021-01-07'))&(df.survey$Date<=as.Date('2021-05-13'))
b.fall20 = (df.survey$Date>=as.Date('2020-08-10'))&(df.survey$Date<=as.Date('2020-12-15'))

df.survey$SEMESTER = NA
df.survey$SEMESTER[b.fall20] = 'Fall 2020'
df.survey$SEMESTER[b.spring21] = 'Spring 2021'

df.summary = df.survey[!is.na(df.survey$SEMESTER),]
df.fall = df.summary[df.summary$SEMESTER == 'Fall 2020',]
df.spring = df.summary[df.summary$SEMESTER == 'Spring 2021',]

p_fall = ggplot(df.fall, aes(x = Date)) +
  geom_linerange(size=1.1, aes(ymin = lower, ymax = upper)) +
  geom_point(size = 4, color = 'black', aes(y = Pct.Pos)) + 
  geom_point(size = 2, color = 'orange', aes(y = Pct.Pos)) + 
  geom_line(size = 2, color = 'red', alpha = 0.6, aes(y = MovingAvg)) +
  theme_bw(base_size=14) + 
  theme(legend.position = 'right'
        #, axis.text.x = element_text(angle = 270, vjust=0.3)
        , panel.grid.minor.x = element_blank()
        , panel.grid.major.x = element_line(color = 'grey80')
        , panel.grid.minor.y = element_blank()
        , panel.grid.major.y = element_line(color='grey80')) +
  scale_x_date(breaks = seq(from = as.Date('2020-08-13'), to = as.Date('2020-11-22'), by = "week")
              , date_minor_breaks = '1 day'
              , labels = date_format("%b-%d")
              , expand = c(0.01,0.01)
              , limits = c(as.Date('2020-08-13'), as.Date('2020-11-19'))) +
  scale_y_continuous(expand = c(0,0), breaks = seq(0, ymax, .5)) + 
  xlab('Date') + 
  ylab('% Positive') +
  facet_wrap(SEMESTER~., scales='free', nrow = 2)
p_fall

p_spring = ggplot(df.spring, aes(x = Date)) +
  geom_linerange(size=1.1, aes(ymin = lower, ymax = upper)) +
  geom_point(size = 4, color = 'black', aes(y = Pct.Pos)) + 
  geom_point(size = 2, color = 'orange', aes(y = Pct.Pos)) + 
  geom_line(size = 2, color = 'red', alpha = 0.6, aes(y = MovingAvg)) +
  theme_bw(base_size=14) + 
  theme(legend.position = 'right'
        #, axis.text.x = element_text(angle = 270, vjust=0.3)
        , panel.grid.minor.x = element_blank()
        , panel.grid.major.x = element_line(color = 'grey80')
        , panel.grid.minor.y = element_blank()
        , panel.grid.major.y = element_line(color='grey80')) +
  scale_x_date(breaks = seq(from = as.Date('2021-01-07'), to = as.Date('2021-05-14'), by = "week")
               , date_minor_breaks = '1 day'
               , labels = date_format("%b-%d")
               , expand = c(0.01,0.01)
               , limits = c(as.Date('2021-01-07'), as.Date('2021-05-14'))) +
  scale_y_continuous(expand = c(0,0), breaks = seq(0, ymax, .5)) + 
  xlab('Date') + 
  ylab('% Positive') + 
  facet_wrap(SEMESTER~., scales='free', nrow = 2)
p_spring

title <- ggdraw() + 
  draw_label(
    "Georgia Tech Asymptomatic COVID-19 Surveillance Data",
    fontface = 'bold', size = 18,
    x = 0,
    hjust = -.112
  ) +
  theme(
    # add margin on the left of the drawing canvas,
    # so title is aligned with left edge of first plot
    plot.margin = margin(0, 0, 0, 0)
  )

p_summary = plot_grid(title, p_fall, p_spring, ncol = 1, rel_heights = c(.5,6,4), labels = c('', 'A', 'B'))

# Save Output
ggsave('2021-08-06_Fall20-Spring21_Trends.png', plot = p_summary, device = 'png', height = 10, width = 14)
ggsave('2021-08-06_Fall20-Spring21_Trends.pdf', plot = p_summary, device = 'pdf', height = 10, width = 14)
