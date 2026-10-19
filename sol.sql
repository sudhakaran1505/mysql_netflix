use netflix_db;
show tables;
select 'movie'as tab, count(*) from movie
union
select 'season'as tab, count(*) from season
union
select 'tv_show'as tab, count(*) from tv_show
union
select 'view_summary' as tab, count(*) from view_summary;


/*  2q   */

