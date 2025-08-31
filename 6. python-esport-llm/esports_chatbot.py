import os
import json
from typing import Optional

import discord
from discord.ext import commands

DATA_FILE = "esports_data.json"

class TournamentManager:
    def __init__(self, data_file=DATA_FILE):
        self.data_file = data_file
        self._load()

    def _load(self):
        if os.path.exists(self.data_file):
            with open(self.data_file, "r", encoding="utf-8") as f:
                self.data = json.load(f)
        else:
            self.data = {
                "tournaments": {},
                "next_player_id": 1
            }
            self._seed()
            self._save()

    def _save(self):
        with open(self.data_file, "w", encoding="utf-8") as f:
            json.dump(self.data, f, indent=2, ensure_ascii=False)

    def _seed(self):
        self.data["tournaments"] = {
            "open_cup_1": {
                "id": "open_cup_1",
                "name": "Open Cup #1",
                "type": "solo",
                "teams": {},
                "players": {},
                "status": "open"
            },
            "team_league_summer": {
                "id": "team_league_summer",
                "name": "Team League - Summer",
                "type": "team",
                "teams": {"Red Dragons": [], "Blue Wolves": []},
                "players": {},
                "status": "open"
            }
        }

    def list_tournaments(self):
        return [{"id": tid, **t} for tid, t in self.data["tournaments"].items()]
    
    def add_tournament(self, tid: str, name: str, t_type: str):
        if t_type not in ["solo", "team"]:
            raise ValueError("Typ turnieju musi być 'solo' albo 'team'.")
        if tid in self.data["tournaments"]:
            raise ValueError("Turniej o takim ID już istnieje.")
        tournament = {
            "id": tid,
            "name": name,
            "type": t_type,
            "teams": {} if t_type == "team" else {},
            "players": {},
            "status": "open"
        }
        self.data["tournaments"][tid] = tournament
        self._save()
        return tournament

    def add_team(self, tid: str, team_name: str):
        tourney = self.data["tournaments"].get(tid)
        if not tourney:
            raise ValueError("Turniej nie istnieje.")
        if tourney["type"] != "team":
            raise ValueError("Do turnieju typu solo nie można dodawać drużyn.")
        if team_name in tourney["teams"]:
            raise ValueError("Taka drużyna już istnieje.")
        tourney["teams"][team_name] = []
        self._save()

    def add_player(self, tid: str, player_name: str, team_name: Optional[str] = None):
        tourney = self.data["tournaments"].get(tid)
        print(tourney["teams"])
        if not tourney:
            raise ValueError("Turniej nie istnieje.")

        if tourney["type"] == "team":
            if not team_name:
                raise ValueError("Ten turniej jest drużynowy — podaj nazwę drużyny.")
            if team_name not in tourney["teams"].keys():
                raise ValueError("Drużyna nie istnieje w tym turnieju.")
        else:  # solo
            if team_name:
                raise ValueError("Turniej solo nie obsługuje drużyn.")

        player_id = f"player_{self.data['next_player_id']}"
        player = {
            "id": player_id,
            "name": player_name,
            "team": team_name if tourney["type"] == "team" else None
        }

        self.data['next_player_id'] += 1
        tourney['players'][player_id] = player
        if tourney["type"] == "team":
            tourney['teams'][team_name].append(player_id)

        self._save()
        return player

    def get_status(self, tid: str):
        tourney = self.data["tournaments"].get(tid)
        if not tourney:
            raise ValueError("Turniej nie istnieje.")
        return {
            "name": tourney["name"],
            "teams": tourney["teams"],
            "players": list(tourney["players"].values()),
            "status": tourney["status"],
            "type": tourney["type"]
        }


# -------- Discord Bot --------
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents, help_command=None)
manager = TournamentManager()

@bot.event
async def on_ready():
    print(f"Bot zalogowany jako {bot.user} (id: {bot.user.id})")

@bot.command(name="help")
async def help_cmd(ctx):
    help_text = (
        "**Dostępne komendy:**\n"
        "`!list` - lista turniejów\n"
        "`!new_tournament <id> <name> <solo|team>` - utwórz turniej\n"
        "`!new_team <tournament_id> <team_name>` - dodaj drużynę do turnieju\n"
        "`!add_player <tournament_id> <player_name> [team_name]` - dodaj gracza\n"
        "`!status <tournament_id>` - status turnieju\n"
    )
    await ctx.send(help_text)

@bot.command(name="list")
async def list_tournaments(ctx):
    tournaments = manager.list_tournaments()
    if not tournaments:
        await ctx.send("Brak dostępnych rozgrywek.")
        return
    lines = [f"{t['id']}: {t['name']} (typ: {t['type']}, status: {t['status']})" for t in tournaments]
    await ctx.send("\n".join(lines))

@bot.command(name="new_tournament")
async def new_tournament(ctx, tid: str = None, name: str = None, t_type: str = None):
    if not tid or not name or not t_type:
        await ctx.send("❌ Użycie: `!new_tournament <id> <name> <solo|team>`")
        return
    try:
        t = manager.add_tournament(tid, name, t_type)
        await ctx.send(f"✅ Dodano turniej **{t['name']}** (ID: {t['id']}) - typ: {t['type']}")
    except Exception as e:
        await ctx.send(f"❌ Błąd: {e}")

@bot.command(name="new_team")
async def new_team(ctx, tid: str = None, *, team_name: str = None):
    if not tid or not team_name:
        await ctx.send("❌ Użycie: `!new_team <tournament_id> <team_name>`")
        return
    try:
        manager.add_team(tid, team_name)
        await ctx.send(f"✅ Dodano drużynę **{team_name}** do turnieju {tid}")
    except Exception as e:
        await ctx.send(f"❌ Błąd: {e}")

@bot.command(name="add_player")
async def add_player(ctx, tid: str = None, player_name: str = None, team_name: str = None):
    if not tid or not player_name:
        await ctx.send("❌ Użycie: `!add_player <tournament_id> <player_name> [team_name]`")
        return
    try:
        player = manager.add_player(tid, player_name, team_name)
        await ctx.send(
            f"✅ Dodano zawodnika **{player['name']}** (ID: {player['id']}) "
            f"do turnieju **{tid}**" + (f" w drużynie **{team_name}**" if team_name else "")
        )
    except Exception as e:
        await ctx.send(f"❌ Błąd: {e}")

@bot.command(name="status")
async def status(ctx, tid: str = None):
    if not tid:
        await ctx.send("❌ Użycie: `!status <tournament_id>`")
        return
    try:
        s = manager.get_status(tid)
        lines = [f"**{s['name']}** (typ: {s['type']}, status: {s['status']})", "Zawodnicy:"]
        for p in s['players']:
            lines.append(f" - {p['id']}: {p['name']}" + (f" [team: {p['team']}]" if p['team'] else ""))
        if s['type'] == "team":
            lines.append("\nDrużyny:")
            if not s["teams"]:
                lines.append(" Brak drużyn.")
            for team, pids in s['teams'].items():
                player_names = [p['name'] for p in s['players'] if p['id'] in pids]
                lines.append(f" {team}: {', '.join(player_names) if player_names else 'brak zawodników'}")
        await ctx.send("\n".join(lines))
    except Exception as e:
        await ctx.send(f"❌ Błąd: {e}")


if __name__ == "__main__":
    token = os.getenv("DISCORD_TOKEN")
    if not token:
        print("Brak DISCORD_TOKEN w zmiennych środowiskowych.")
    else:
        bot.run(token)
