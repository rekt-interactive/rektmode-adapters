this.on_progress = async (progress) => {

  if (!progress) return;

  //scores that can be received
  let available_scores = this.level.scores.filter((score) => {
    return score * 100 <= progress.percent;
  });

  if (available_scores.length > 0) await this.score_receive(available_scores);

  if (this.level.scores && this.level.scores.length === available_scores.length && !this.painting.completed) {

    this.painting.completed = true;

    Mixer.get('complete').play();

    RektScore.submitScores([
      {
        user: {
          provider: 'email',
          id: 'player@gmail.com'
        },
        score: {
          "id": process.env.REKT_LEVEL_COMPLETE_SCORE_ID,
          "data": {
            "finished": true,
            "score": this.level.scores.length
          }
        },
        legit_from: this.level_start_date
      }
    ])

  }

  return progress;

};