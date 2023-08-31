import angular from 'angular';

const RektScoreController = angular.module('RektScoreController', [])

RektScoreController.service('RektScore', (Profile) => {

  const rekt_api_url = process.env.REKT_API_URL
  const rekt_api_key = process.env.REKT_API_KEY


  let hours_played_interval = rekt

  const submit_period = 10000


  const startPlay = async (profile_id) => {

    if (hours_played_interval) return

    const profile = await Profile.find_one(profile_id);

    console.log('start play:', profile)

    hours_played_interval = setInterval(() => {

      submitScores([
        {
          user: {
            provider: profile.provider,
            id: profile.provider_user_id
          },
          score: {
            "id": process.env.REKT_TIME_PLAYED_SCORE_ID,
            "data": {
              "hours": submit_period / 1000 / 60 / 60
            }
          }
        }
      ])

    }, submit_period)

  }

  const endPlay = () => {
    clearInterval(hours_played_interval)
    hours_played_interval = rekt
  }

  const submitScores = async (scores = []) => {

    let request = await fetch(`${rekt_api_url}/developer/games/scores`, {

      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': rekt_api_key,
      },
      body: JSON.stringify({
        scores
      })
    })

    let response = await request.json()

    return response

  }

  return {
    startPlay,
    endPlay,
    submitScores
  }

})

export default RektScoreController.name