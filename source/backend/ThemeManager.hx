package backend;

import states.ultramenus.turkey.*;
import states.ultramenus.original.*;
import states.ultramenus.v1.*;
import states.*;

class ThemeManager
{
    // ── ANA MENÜ ────────────────────────────────────────────────
    public static function switchToMainMenu():Void
    {
        switch (getTheme())
        {
            case 'TÜRKIYE' | 'TURKIYE':
                MusicBeatState.switchState(new states.ultramenus.turkey.MainMenuTurkey());
            case 'ORJINAL':
                MusicBeatState.switchState(new states.ultramenus.original.MainMenuOriginal());
            case 'V1':
                MusicBeatState.switchState(new states.ultramenus.v1.MainMenuV1());
            default:
                MusicBeatState.switchState(new states.MainMenuState());
        }
    }
		// ── PLAY STATE (Loading ile) ─────────────────────────────────
	public static function loadAndSwitchToPlay():Void
	{
		states.LoadingState.loadAndSwitchState(new states.PlayState());
	}

	// ── STORY MENU (Loading ile) ─────────────────────────────────
	public static function loadAndSwitchToStoryMenu():Void
	{
		switch (getTheme())
		{
			case 'TÜRKIYE' | 'TURKIYE':
				states.LoadingState.loadAndSwitchState(new states.ultramenus.turkey.StoryMenuTurkey());
			case 'ORJINAL':
				states.LoadingState.loadAndSwitchState(new states.ultramenus.original.StoryMenuOriginal());
			case 'V1':
				states.LoadingState.loadAndSwitchState(new states.ultramenus.v1.StoryMenuV1());
			default:
				states.LoadingState.loadAndSwitchState(new states.StoryMenuState());
		}
	}

	// ── FREEPLAY (Loading ile) ───────────────────────────────────
	public static function loadAndSwitchToFreeplay():Void
	{
		switch (getTheme())
		{
			case 'TÜRKIYE' | 'TURKIYE':
				states.LoadingState.loadAndSwitchState(new states.ultramenus.turkey.FreeplayTurkey());
			case 'ORJINAL':
				states.LoadingState.loadAndSwitchState(new states.ultramenus.original.FreeplayOriginal());
			case 'V1':
				states.LoadingState.loadAndSwitchState(new states.ultramenus.v1.FreeplayV1());
			default:
				states.LoadingState.loadAndSwitchState(new states.FreeplayState());
		}
	}

	// ── TITLE - Tema yok, her zaman default ─────────────────────
	public static function switchToTitle():Void
	{
		MusicBeatState.switchState(new states.TitleState());
	}

    // ── FREEPLAY ────────────────────────────────────────────────
    public static function switchToFreeplay():Void
    {
        switch (getTheme())
        {
            case 'TÜRKIYE' | 'TURKIYE':
                MusicBeatState.switchState(new states.ultramenus.turkey.FreeplayTurkey());
            case 'ORJINAL':
                MusicBeatState.switchState(new states.ultramenus.original.FreeplayOriginal());
            case 'V1':
                MusicBeatState.switchState(new states.ultramenus.v1.FreeplayV1());
            default:
                MusicBeatState.switchState(new states.FreeplayState());
        }
    }

    // ── STORY MENU ──────────────────────────────────────────────
    public static function switchToStoryMenu():Void
    {
        switch (getTheme())
        {
            case 'TÜRKIYE' | 'TURKIYE':
                MusicBeatState.switchState(new states.ultramenus.turkey.StoryMenuTurkey());
            case 'ORJINAL':
                MusicBeatState.switchState(new states.ultramenus.original.StoryMenuOriginal());
            case 'V1':
                MusicBeatState.switchState(new states.ultramenus.v1.StoryMenuV1());
            default:
                MusicBeatState.switchState(new states.StoryMenuState());
        }
    }

    // ── ACHIEVEMENTS ────────────────────────────────────────────
    public static function switchToAchievements():Void
    {
        switch (getTheme())
        {
            case 'TÜRKIYE' | 'TURKIYE':
                MusicBeatState.switchState(new states.ultramenus.turkey.AchievementsTurkey());
            case 'ORJINAL':
                MusicBeatState.switchState(new states.ultramenus.original.AchievementsOriginal());
            case 'V1':
                MusicBeatState.switchState(new states.ultramenus.v1.AchievementsV1());
            default:
                MusicBeatState.switchState(new states.AchievementsMenuState());
        }
    }

    // ── CREDITS ─────────────────────────────────────────────────
    public static function switchToCredits():Void
    {
        switch (getTheme())
        {
            case 'TÜRKIYE' | 'TURKIYE':
                MusicBeatState.switchState(new states.ultramenus.turkey.CreditsTurkey());
            case 'ORJINAL':
                MusicBeatState.switchState(new states.ultramenus.original.CreditsOriginal());
            case 'V1':
                MusicBeatState.switchState(new states.ultramenus.v1.CreditsV1());
            default:
                MusicBeatState.switchState(new states.CreditsState());
        }
    }

    // ── MODS ────────────────────────────────────────────────────
    #if MODS_ALLOWED
    public static function switchToMods(?modFolder:String):Void
    {
        switch (getTheme())
        {
            case 'TÜRKIYE' | 'TURKIYE':
                MusicBeatState.switchState(new states.ultramenus.turkey.ModsMenuTurkey(modFolder));
            case 'ORJINAL':
                MusicBeatState.switchState(new states.ultramenus.original.ModsMenuOriginal(modFolder));
            case 'V1':
                MusicBeatState.switchState(new states.ultramenus.v1.ModsMenuV1(modFolder));
            default:
                MusicBeatState.switchState(new states.ModsMenuState(modFolder));
        }
    }
    #end

	// ── OPTIONS - Tema yok, her zaman default ───────────────────
	public static function switchToOptions(?onPlayState:Bool = false):Void
	{
		options.OptionsState.onPlayState = onPlayState;
		MusicBeatState.switchState(new options.OptionsState());
	}

    // ── YARDIMCI FONKSİYONLAR ───────────────────────────────────
    public static function getTheme():String
    {
        var theme:String = ClientPrefs.data.menuTheme;
        if (theme == null) theme = 'V3';
        return theme.toUpperCase();
    }

    public static function isTurkey():Bool
    {
        return getTheme() == 'TÜRKIYE' || getTheme() == 'TURKIYE';
    }

    public static function isV3():Bool return getTheme() == 'V3';
    public static function isOriginal():Bool return getTheme() == 'ORJINAL';
    public static function isV1():Bool return getTheme() == 'V1';
}