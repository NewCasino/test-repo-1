namespace Luxbook.MVC.Repositories
{
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Infrastructure;
    using Models;

    public interface ITraderRepository
    {
        void UpdatePreferences(Trader trader);
        Trader GetTrader(string username);
        List<Trader> GetAllTraders();
    }

    public class TraderRepository : ITraderRepository
    {
        private readonly IDatabase _database;

        public TraderRepository(IDatabase database)
        {
            _database = database;
        }


        public void UpdatePreferences(Trader trader)
        {
            _database.Execute(
                @"UPDATE TRADER
                    SET ALERT_GAME_TYPES = @gameTypes,    
                    ALERT_CONTINENTS = @continents,    
                    ALERT_MINIMUM_PERCENTAGE = @minimumPercentage,
                    ALERT_START_TIME_FILTER = @startTime,
                    ALERT_END_START_TIME_FILTER = @endTime
                WHERE LID = @lid",
                new
                {
                    gameTypes = trader.GameTypes,
                    continents = trader.Continents,
                    minimumPercentage = trader.MinimumPercentage,
                    lid = trader.Username,
                    startTime = trader.RaceStartTimeFilter,
                    endTime = trader.RaceEndStartTimeFilter
                }, commandType: CommandType.Text);
        }


        public Trader GetTrader(string username)
        {
            return
                _database.Query<Trader>(
                    @"SELECT 
                        LID as Username, 
                        Name, 
                        IsNull(ALERT_GAME_TYPES, GAME) as GameTypes, 
                        IsNull(ALERT_CONTINENTS,CNTL) as Continents, 
                        ALERT_MINIMUM_PERCENTAGE as MinimumPercentage,
                        ALERT_START_TIME_FILTER as RaceStartTimeFilter,
                        ALERT_END_START_TIME_FILTER as RaceEndStartTimeFilter ,
                        OPRT As Operator
                    FROM TRADER WHERE LID = @lid",
                    new {LID = username}, commandType: CommandType.Text)
                    .FirstOrDefault();
        }

        public List<Trader> GetAllTraders()
        {
            return _database.Query<Trader>(@"SELECT 
                        LID as Username, 
                        Name, 
                        IsNull(ALERT_GAME_TYPES, GAME) as GameTypes, 
                        IsNull(ALERT_CONTINENTS,CNTL) as Continents, 
                        ALERT_MINIMUM_PERCENTAGE as MinimumPercentage,
                        ALERT_START_TIME_FILTER as RaceStartTimeFilter,
                        ALERT_END_START_TIME_FILTER as RaceEndStartTimeFilter,
                        OPRT as OPERATOR
                        FROM TRADER", commandType: CommandType.Text).ToList();
        }
    }
}