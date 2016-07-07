namespace Luxbook.MVC.Repositories
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using Infrastructure;
    using Models;

    public interface ISystemRepository
    {
        List<SystemEnum> GetSystemEnums();
        List<Staking> GetStakings();
        void UpdateStakings(List<Staking> stakings);
        List<Bettekk> GetVenueCodes();
        void UpdateVenues(List<Bettekk> venues);
    }

    public class SystemRepository : ISystemRepository
    {
        private readonly IDatabase _database;

        public SystemRepository(IDatabase database)
        {
            _database = database;
        }

        public List<SystemEnum> GetSystemEnums()
        {
            return _database.Query<SystemEnum>("SELECT * FROM SYS_ENUM", commandType: CommandType.Text).ToList();
        }

        public List<Staking> GetStakings()
        {
            return _database.Query<Staking>("SELECT * FROM SYS_STAKING", commandType: CommandType.Text).ToList();
        }

        public List<Bettekk> GetVenueCodes()
        {
            return _database.Query<Bettekk>("SELECT * FROM SYS_BETTEKK", commandType: CommandType.Text).ToList();
        }

        public void UpdateVenues(List<Bettekk> venues)
        {
            if (!venues.Any())
            {
                return;
            }

            var parameters = venues.Select(x => $"('{x.Code}','{x.Region}','{x.Alt_Venue}','{x.Betfair}','{x.Country}','{x.GCode}','{x.GTFav}','{x.GtxCode}','{x.Rank}','{x.State}','{x.Type}','{x.Venue}')");
            var sql = @"UPDATE SYS_BETTEKK SET REGION=x.zRegion, ALT_VENUE=x.zAlternateVenue, BETFAIR = x.zBetfair, COUNTRY = x.zCountry, GCODE=x.zGCode, GTFAV = x.zGTFav, [RANK] = x.zRANK, STATE = x.zSTATE, [TYPE] = x.zTYPE, VENUE = x.zVENUE
                        FROM (VALUES{0}) 
                        x (zCode,zRegion,zAlternateVenue,zBetfair,zCountry,zGCode, zGTFav, zGtxCode, zRank, zState, zType, zVenue) WHERE CODE = x.zCode";

            _database.Execute(string.Format(sql, string.Join(",", parameters)), commandType: CommandType.Text);
        }

        public void UpdateStakings(List<Staking> stakings)
        {
            var sql =
                "UPDATE SYS_STAKING SET POOL_TCK = @POOL_TCK, EXP_MIN = @EXP_MIN, EXP_TCK = @EXP_TCK, TKO_AMT = @TKO_AMT, TKO_PCT = @TKO_PCT, TKO_TCK = @TKO_TCK WHERE STAKING_ID = @STAKING_ID";


            var sqlFormat =
                "UPDATE SYS_STAKING SET " +
                "POOL_TCK = x.zPOOL_TCK, EXP_MIN = x.zEXP_MIN, EXP_TCK = x.zEXP_TCK, TKO_AMT = x.zTKO_AMT, TKO_PCT = x.zTKO_PCT, TKO_TCK = x.zTKO_TCK " +
                "FROM (VALUES{0}) " +
                "x (zPool_Tck,zExp_Min,zExp_Tck,zTko_Amt,zTko_Pct,zTko_Tck,zStaking_Id) WHERE STAKING_ID = x.zSTAKING_ID";
            var parameters = new List<string>();
            foreach (var staking in stakings)
            {
                parameters.Add($"({Convert.ToInt32(staking.Pool_Tck)}, {staking.Exp_Min}, {Convert.ToInt32(staking.Exp_Tck)}, {staking.Tko_Amt}, {staking.Tko_Pct}, {Convert.ToInt32(staking.Tko_Tck)}, {staking.Staking_Id} )");
                //_database.Execute(sql, new                                                                                                                                                   
                //{                                                                                                                                                                            
                //    staking.zPool_Tck,
                //    staking.zExp_Min,
                //    staking.zExp_Tck,
                //    staking.zTko_Amt,
                //    staking.zTko_Pct,
                //    staking.zTko_Tck,
                //    staking.zStaking_Id
                //}, commandType:CommandType.Text);
            }

            _database.Execute(string.Format(sqlFormat, string.Join(",", parameters)), new { z = 1 }, commandType: CommandType.Text);
        }
    }
}