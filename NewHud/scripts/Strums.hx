using StringTools;

var strumPositionOffset:Int = 100;
function onCountdownStarted()
{
  for (i in 0...4)
  {
    var plrStrum = game.playerStrums.members[i];
    if (plrStrum != null)
    {
      if (ClientPrefs.data.middleScroll)
      {
        plrStrum.screenCenter(0x01);
        plrStrum.x += (i - 1.5) * Note.swagWidth;
      }
      else
      {
        plrStrum.x = FlxG.width - strumPositionOffset - ((4 - i) * Note.swagWidth);
      }

      plrStrum.sustainReduce = false;
    }

    var oppStrum = game.opponentStrums.members[i];
    if (oppStrum != null)
    {
      oppStrum.x = strumPositionOffset + (i * Note.swagWidth);
      if (ClientPrefs.data.middleScroll && i > 1)
      {
        oppStrum.x += FlxG.width * .5;
      }

      oppStrum.sustainReduce = false;
    }
  }
}

function processForStrum(note:Note)
{
  if (!note.isSustainNote || note.parent == null || !note.animation.name.endsWith('end'))
  {
    return;
  }

  var strum = (note.mustPress ? game.playerStrums : game.opponentStrums).members[note.noteData];
  if (strum == null)
  {
    return;
  }

  if (note.mustPress)
  {
    strum.playAnim('pressed');
    strum.resetAnim = game.cpuControlled ? Conductor.stepCrochet * .00125 / game.playbackRate : 0;
  }
  else
  {
    strum.playAnim('static');
    strum.resetAnim = 0;
  }
}

function opponentNoteHit(note:Void)
{
  processForStrum(note);
}
function goodNoteHit(note:Void)
{
  processForStrum(note);
}