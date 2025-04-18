package funkin.ui.freeplay.charselect;

import funkin.data.IRegistryEntry;
import funkin.data.freeplay.player.PlayerData;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.play.scoring.Scoring.ScoringRank;

/**
 * An object used to retrieve data about a playable character (also known as "weeks").
 * Can be scripted to override each function, for custom behavior.
 */
@:nullSafety
class PlayableCharacter implements IRegistryEntry<PlayerData>
{
  /**
   * The ID of the playable character.
   */
  public final id:String;

  /**
   * Playable character data as parsed from the JSON file.
   */
  public final _data:Null<PlayerData>;

  /**
   * @param id The ID of the JSON file to parse.
   */
  public function new(id:String)
  {
    this.id = id;
    _data = _fetchData(id);

    if (_data == null)
    {
      throw 'Could not parse playable character data for id: $id';
    }
  }

  /**
   * Retrieve the readable name of the playable character.
   */
  public function getName():String
  {
    /**
     * Checking to see if `_data`, and `_data.name` is not `null` before returning it
     * If either is `null`, it will return `"Unknown"`.
     */
    return (_data != null && _data.name != null) ? _data.name : "Unknown";

    /**
     * As for localized string support
     * you could eventually map the string `"Unknown"` to the appropiate translation depending on the current language
     * `getLocalizedString("unknown_name")` would return the translated value base on the current locale
     */
    return (_data != null && _data.name != null) ? _data.name : getLocalizedString("unknown_name");
  }

  /**
   * Retrieve the list of stage character IDs associated with this playable character.
   * @return The list of associated character IDs
   */
  public function getOwnedCharacterIds():Array<String>
  {
    return (_data != null && _data.ownedChars != null) ? _data.ownedChars : [];
  }

  /**
   * Return `true` if, when this character is selected in Freeplay,
   * songs unassociated with a specific character should appear.
   */
  public function shouldShowUnownedChars():Bool
  {
    return (_data != null && _data.showUnownedChars != null) ? _data.showUnownedChars : false;
  }

  public function shouldShowCharacter(id:String):Bool
  {
    if (getOwnedCharacterIds().contains(id))
    {
      return true;
    }

    if (shouldShowUnownedChars())
    {
      var result = !PlayerRegistry.instance.isCharacterOwned(id);
      return result;
    }

    return false;
  }

  public function getFreeplayStyleID():String
  {
    return (_data != null && _data.freeplayStyle != null) ? _data.freeplayStyle : Constants.DEFAULT_FREEPLAY_STYLE;
  }

  public function getFreeplayDJData():Null<PlayerFreeplayDJData>
  {
    return (_data != null) ? _data.freeplayDJ : null;
  }

  public function getFreeplayDJText(index:Int):String
  {
    // Silly little placeholder
    return (_data != null && _data.freeplayDJ != null) ? _data.freeplayDJ.getFreeplayDJText(index) : 'GET FREAKY ON A FRIDAY';
  }

  public function getCharSelectData():Null<PlayerCharSelectData>
  {
    return (_data != null) ? _data.charSelect : null;
  }

  /**
   * @param rank Which rank to get info for
   * @return An array of animations. For example, BF Great has two animations, one for BF and one for GF
   */
  public function getResultsAnimationDatas(rank:ScoringRank):Array<PlayerResultsAnimationData>
  {
    if (_data == null || _data.results == null)
    {
      return [];
    }

    switch (rank)
    {
      case PERFECT_GOLD:
        return _data.results.perfectGold;
      case PERFECT:
        return _data.results.perfect;
      case EXCELLENT:
        return _data.results.excellent;
      case GREAT:
        return _data.results.great;
      case GOOD:
        return _data.results.good;
      case SHIT:
        return _data.results.loss;
    }
  }

  public function getResultsMusicPath(rank:ScoringRank):String
  {
    switch (rank)
    {
      case PERFECT_GOLD:
        return (_data != null
          && _data.results != null
          && _data.results.music != null
          && _data.results.music.PERFECT_GOLD != null) ? _data.results.music.PERFECT_GOLD : "resultsPERFECT";
      case PERFECT:
        return
          (_data != null && _data.results != null && _data.results.music != null && _data.results.music.PERFECT != null) ? _data.results.music.PERFECT : "resultsPERFECT";

      case EXCELLENT:
        return
          (_data != null && _data.results != null && _data.results.music != null && _data.results.music.EXCELLENT != null) ? _data.results.music.EXCELLENT : "resultsEXCELLENT";

      case GREAT:
        return
          (_data != null && _data.results != null && _data.results.music != null && _data.results.music.GREAT != null) ? _data.results.music.GREAT : "resultsNORMAL";

      case GOOD:
        return
          (_data != null && _data.results != null && _data.results.music != null && _data.results.music.GREAT != null) ? _data.results.music.GREAT : "resultsNORMAL";

      case SHIT:
        return
          (_data != null && _data.results != null && _data.results.music != null && _data.results.music.SHIT != null) ? _data.results.music.SHIT : "resultsSHIT";

      default:
        return
          (_data != null && _data.results != null && _data.results.music != null && _data.results.music.GOOD != null) ? _data.results.music.GOOD : "resultsNORMAL";
    }
  }

  /**
   * Returns whether this character is unlocked.
   */
  public function isUnlocked():Bool
  {
    return (_data != null && _data.unlocked != null) ? _data.unlocked : true;
  }

  /**
   * Called when the character is destroyed.
   * TODO: Document when this gets called
   */
  public function destroy():Void {}

  public function toString():String
  {
    return 'PlayableCharacter($id)';
  }

  /**
   * Retrieve and parse the JSON data for a playable character by ID.
   * @param id The ID of the character
   * @return The parsed player data, or null if not found or invalid
   */
  static function _fetchData(id:String):Null<PlayerData>
  {
    return PlayerRegistry.instance.parseEntryDataWithMigration(id, PlayerRegistry.instance.fetchEntryVersion(id));
  }
}
