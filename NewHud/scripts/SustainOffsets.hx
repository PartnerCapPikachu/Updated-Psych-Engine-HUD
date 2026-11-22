using StringTools;

function onCreatePost()
{
  for (note in game.unspawnNotes) if (note.isSustainNote)
  {
    if (!PlayState.isPixelStage)
    {
      note.scale.set(.7, .7);
      if (!note.animation.name.endsWith('end'))
      {
        note.scale.y = (Conductor.getBPMFromSeconds(note.parent.strumTime + FlxMath.EPSILON).stepCrochet * .45 * game.songSpeed / game.playbackRate) / note.frameHeight;
        note.updateHitbox();
      }
      else
      {
        note.updateHitbox();
        for (tail in note.parent.tail)
          tail.offsetY -= ClientPrefs.data.downScroll ? -note.height : note.height;
      }
    }
    else if (note.animation.name.endsWith('end'))
    {
      for (tail in note.parent.tail)
        tail.offsetY -= ClientPrefs.data.downScroll ? -note.height : note.height;
    }
  }
}