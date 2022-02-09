<template>
  <Experiment title="_magpie mental-rotation">
    <InstructionScreen :title="'Welcome'">
      Welcome to this short psychology experiment (~10 minutes). Thank you for participating!
      <br />  <br />
      Click next to learn more about the experimental task.
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
      The trials are divided in six blocks. Before each block we will inform you about the specific letter you should look for. This letter does not change between trials only between blocks.
      <br />
      <br />
      Each trial is conceptualised as follows:
      <ul>
        <li>Fixation: Please fixate the center of a cross that will be displayed.</li>
        <li>Task: Please search for the specific letter as fast and accurate as possible.</li>
        <li>Feedback: After each trial you will be told if the response was correct or incorrect.</li>
      </ul>
      <br />
    </InstructionScreen>

    <InstructionScreen :title="'Calibration'">
      To ensure that the trials are presented correctly, it is necessary to shortly calibrate the size of your browser window.
      Please adjust the size of your browser window (zoom option) such that the displayed form roughly matches the size of an actual crdit card or ID card.
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
        <span v-if="block[0].condition === 'disjunction'">
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
          :feedbackTime="200000"
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
            <p v-if="$magpie.measurements.response == $magpie.measurements.expected"> Correct! Your reaction time was {{getLastRT($magpie.trialData)}} milliseconds</p>
            <p v-else> Wrong!</p>
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
import conjunction_trials from '../trials/conjunction_trials.csv';
import disjunction_trials from '../trials/disjunction_trials.csv';
import _ from 'lodash';

// block randomization
//let blockorder = _.shuffle(['CDDCCD', 'DCCDDC'])[0];
let blockorder = _.shuffle(['C', 'D'])[0];

// double trials from 64 to 128, suich that each apears twice in a block
let conjunction_block = conjunction_trials.concat(conjunction_trials);
let disjunction_block = disjunction_trials.concat(disjunction_trials);

// create blocks accoridng to block order
let blocks = [];
let target_names = [];
for(const block of blockorder){
  blocks.push(block == 'C' ? _.shuffle(conjunction_block) : _.shuffle(disjunction_block));
  target_names.push()
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
            let last_trial = json[last_Key];
            return last_trial[0].response_time;

          } else {
            return 'empty'
          }
      }
    }
};

</script>
