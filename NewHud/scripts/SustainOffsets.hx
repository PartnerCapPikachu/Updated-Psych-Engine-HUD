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
        note.setGraphicSize(note.width, Conductor.getBPMFromSeconds(note.parent.strumTime + FlxMath.EPSILON).stepCrochet * .45 * songSpeed / playbackRate);
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