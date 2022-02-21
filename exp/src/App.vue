<template>
  <Experiment title="_magpie mental-rotation">
    <InstructionScreen :title="'Welcome'">
      Welcome and thank you for participating!
     <br/> <br />

      In this short psychology experiment (~10 minutes) we will collect anonymous data only
      (e.g., accuracy of response and response times). The study is conducted by a student seminar at the University of Tuebingen.
      You will not be compensated for your time, except for a sincere thank you for taking an active part in science.

      However, if you do not feel like participating you can stop the experiment at any time by closing the tab.
      If you have further questions feel free to contact us via <a href="mailto:frederic.becker@student.uni-tuebingen.de">email</a>.
      <br />  <br />
      Click next to learn more about your task.
    </InstructionScreen>

    <InstructionScreen :title="'Task'">
      In the task you will be presented different letters scattered across the screen.
      Your task is to decide whether a specific letter (e.g. a red X) is present or not.
      <br />
      <br />
      Please press button <b>J</b> on your keyboard if the letter in question is <b>present</b>.
      <br />
      Please press button <b>F</b> on your keyboard if the letter in question is<b> not present</b>.

      <br />
      <br />
      It is important that you try to respond as fast and as correct as possible!
      <br />
    </InstructionScreen>

    <InstructionScreen :title="'Procedure'">
      The experiment consists of two task blocks. Prior to each block we will inform you about the specific target letter you are supposed to look out for.
      <b>The target letter only changes between blocks not between trials!</b>
      <br /><br />
      After each block you will get the chance to take a short pause if you like before you continue with the next block.
      <br />
    </InstructionScreen>

    <InstructionScreen :title="'Calibration'">
      To ensure that the trials are presented correctly, it is necessary to shortly calibrate the size of your browser window.
      Please adjust the size of your browser window (zoom option, press ctrl/strg and ‘+’ or ‘-‘) such that the displayed form roughly matches the size of an actual credit card or ID card.
      <br/>  <br/>
      <div style="width: 375px; height: 230px; border-radius: 10px; background-color: grey; margin-left: auto; margin-right: auto;"></div>
      <br/>
      Please position yourself so that:
      <ul>
        <li>the screen is about an arm's length away from you</li>
        <li>your left index finger is located on the button F</li>
        <li>your right index finger is located on the button J</li>
      </ul>
      Click next to start the experiment. Good luck!
      <br />
    </InstructionScreen>

    <!-- Loop over blocks in the order given-->
    <template v-for="(block, i) of blocks">
      <InstructionScreen :title="'New Block'">
        In the upcoming trials your task to search for
        <span v-if="block[0].condition === 'feature'">
          an <b>S or any <span style='color: blue'> blue</span> letter.</b>
        </span>
        <span v-else>
          a<b><span style='color: green'> green T.</span></b>
        </span>
      </InstructionScreen>

      <!-- Loop over trials within a block-->
      <template v-for="(trial, j) of block">
        <KeypressScreen
          :keys="{'f': 'negative', 'j': 'positive'}"
          :progress="i / block.length"
          :fixationTime= "1000"
          :feedbackTime="2000"
        >
          <template #stimulus>
            <img :src="trial.picture" />
            <Record :data="{
                image: trial.picture,
                target: trial.target,
                target_color: trial.target_color,
                display_size: trial.display_size,
                expected: trial.expected,
                condition: trial.condition,
                trial_number: j,
                block_number: i
              }" />
          </template>

          <template #feedback>
            <p v-if="$magpie.measurements.response == $magpie.measurements.expected"> Correct!</p>
            <p v-else> Wrong!</p>
            Your reaction time was {{getLastRT($magpie.trialData)}} milliseconds
          </template>
        </KeypressScreen>
      </template>
    </template>

    <PostTestScreen />

    <!-- While developing your experiment, using the DebugResults screen is fine,
      once you're going live, you can use the <SubmitResults> screen to automatically send your experimental data to the server.
    -->

    <!-- SubmitResultsScreen/ -->
    <DebugResultsScreen/>
  </Experiment>
</template>

<script>

// Load data from csv files as javascript arrays with objects
import feature_trials1 from '../trials/feature1.csv';
import feature_trials2 from '../trials/feature2.csv';

import disjunction_trials1 from '../trials/disjunction1.csv';
import disjunction_trials2 from '../trials/disjunction2.csv';

import _ from 'lodash';

// block randomization
let blockorder = _.shuffle(['CDCD', 'DCDC'])[0];

// randomize within conditions
let conjunction_blocks = _.shuffle([feature_trials1, feature_trials2]);
let disjunction_blocks = _.shuffle([disjunction_trials1, disjunction_trials2]);

// create blocks according to block order
let blocks = [];
for(const block of blockorder){
  blocks.push(block == 'C' ? _.shuffle(conjunction_blocks.pop()) : _.shuffle(disjunction_blocks.pop()));
}

export default {
  name: 'App',
  data() {

    return {
      blockorder: blockorder,
      blocks: blocks,

      // Expose lodash.range to template above
      range: _.range
    };
  },

  mounted() {
    this.$magpie.addExpData({
      blockorder : this._data.blockorder});
  },

  methods: {
      getLastRT(trial_data) {
          if(Object.keys(trial_data).length > 0){
            let last_key = Object.keys(trial_data).sort().reverse()[0];
            let last_trial = trial_data[last_key];

            console.log(last_trial)
            return last_trial[0].response_time;

          } else {
            return 'empty'
          }
      }
    }
};

</script>
