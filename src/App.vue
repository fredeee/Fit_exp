<template>
  <Experiment title="_magpie mental-rotation">
    <InstructionScreen :title="'Welcome'">
      Welcome to this short experiment (~10 minutes) on visual cognition. Thank you for participating!
      <br />  <br />
      Click next to learn more about the experimental task.
    </InstructionScreen>

    <InstructionScreen :title="'General Instructions'">
      <h2>Task:</h2>
      In the following 11 trials you will be presented two images of gemoetric cubes.
      Your task is to decide whether both cubes share the same shape or not.
      <br />
      <br />
      Please press button  <b>f</b> on your keyboard if you think that the cubes have <b>{{keys[0]}}</b> shapes.
      <br />
      Please press button  <b>j</b> on your keyboard if you think that the cubes have <b>{{keys[1]}}</b> shapes.

      <br />
      <br />
      It is important that you try to response as fast and as correct as possible!

      <br />
      Good luck!
    </InstructionScreen>

    <!-- Here we create screens in a loop for every entry in forced_choice -->
    <template v-for="(training_trial, i) of training_trials">
      <KeypressScreen
        :keys="{'f': keys[0], 'j': keys[1]}"
        :progress="i / training_trials.length"
        :question="training_trial.question"
        :options="[training_trial.option1, training_trial.option2]"
        :fixationTime= "Math.floor(Math.random() * 1500 + 500)"
        :responseTime="7500"
        :feedbackTime="800"
      >
        <template #stimulus>
          <img :src="training_trial.picture" />
          <Record :data="{
              image: training_trial.picture,
              angle: training_trial.angle,
              expected: training_trial.expected,
              item: training_trial.item,
              trial_type: 'training',
              trial_number: i
            }" />
        </template>

        <template #feedback>
          <p v-if="!$magpie.measurements.hasOwnProperty('response')">Faster!</p>
          <p v-else-if="$magpie.measurements.response == $magpie.measurements.expected"> Correct! </p>
          <p v-else> Wrong!</p>
        </template>
      </KeypressScreen>
    </template>

    <PostTestScreen />

    <!-- While developing your experiment, using the DebugResults screen is fine,
      once you're going live, you can use the <SubmitResults> screen to automatically send your experimental data to the server.

      <template #feedback>
        <p v-if="!$magpie.measurements.hasOwnProperty('response')">Faster!</p>
        <p v-else-if="!$magpie.measurements.hasOwnProperty('response')"> Wrong </p>
        <p v-else> Correct </p>
      </template>

      mounted() { this.$magpie.addExpData({
          same_key : same_key });
      }

    -->
    <SubmitResultsScreen/>
  </Experiment>
</template>

<script>

// Load data from csv files as javascript arrays with objects
import main_trials from '../trials/mr_main_trials.csv';
import training_trials from '../trials/mr_training_trials.csv';

import _ from 'lodash';

export default {
  name: 'App',
  data() {

    return {
      main_trials: _.shuffle(main_trials),
      training_trials: _.shuffle(training_trials),
      imageSelection: _.shuffle(imageSelection),
      sliderRating,
      keys: _.shuffle(['same', 'different']),

      // Expose lodash.range to template above
      range: _.range
    };
  },

  mounted() {
    // store same key
    let same_key = this._data.keys[0] == 'same' ? 'f' : 'j';
    this.$magpie.addExpData({
      same_key : same_key  });
  }
};

const imageSelection = [
  {
    QUD: 'image selection - loop: 1, trial: 1',
    question: 'How are you today?',
    option1: 'fine',
    picture1: 'images/question_mark_02.png',
    option2: 'great',
    picture2: 'images/question_mark_01.png'
  },
  {
    QUD: 'image selection - loop: 1, trial: 2',
    option1: 'shiny',
    picture1: 'images/question_mark_03.jpg',
    option2: 'rainbow',
    picture2: 'images/question_mark_04.png'
  },
  {
    QUD: 'image selection - loop: 2, trial: 1',
    question: 'How are you today?',
    option1: 'fine',
    picture1: 'images/question_mark_03.jpg',
    option2: 'great',
    picture2: 'images/question_mark_01.png'
  },
  {
    QUD: 'image selection - loop: 2, trial: 2',
    option1: 'shiny',
    picture1: 'images/question_mark_02.png',
    option2: 'rainbow',
    picture2: 'images/question_mark_04.png'
  }
];

const sliderRating = [
  {
    picture: 'images/question_mark_02.png',
    question: 'How are you today?',
    optionLeft: 'fine',
    optionRight: 'great'
  },
  {
    picture: 'images/question_mark_01.png',
    question: "What's the weather like?",
    optionLeft: 'shiny',
    optionRight: 'rainbow'
  },
  {
    QUD: 'Here is a sentence that stays on the screen from the very beginning',
    picture: 'images/question_mark_03.jpg',
    question: "What's on the bread?",
    optionLeft: 'ham',
    optionRight: 'jam'
  }
];
</script>
