import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';
import { AntagInfoHeader } from './common/AntagInfoHeader';

type Info = {
  antag_name: string;
  objectives: Objective[];
  gang: string;
};
export const AntagInfoGangBoss = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives, antag_name, gang } = data;
  return (
    <Window width={620} height={500} theme="neutral">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name={`${antag_name || 'Gang Boss'} of the ${gang} gang`} asset="changeling.gif" />
          </Stack.Item>
          <Stack.Item>
            You are a Gang Boss your objective is to make sure your gang has more Reputation than any of the others.
          </Stack.Item>
          <Stack.Item>
            You can recruit others by Inviting with the action button on the top left of the screen, theyll have to accept the
            invitation to be recruited.
          </Stack.Item>
          <Stack.Item>The suspicious device in your backpack allows for the purchase of equipment with Influence.</Stack.Item>
          <Stack.Item>
            The most basic way of gaining influence is having your gang members wear the gang uniform, members not wearing it
            will make you lose it instead.
          </Stack.Item>
          <Stack.Item>Below are covered other methods of gaining Influence and Reputation:</Stack.Item>
          <Stack.Item>
            - Territory: The purchaseable spraycan allows you to tag areas, periodically netting you Influence end Reputation,
            its risky as losing tags reduces Reputation instead.
          </Stack.Item>
          <Stack.Item>
            - Credits: After ten minutes have passed since round start the Gang with the most credits will gain a great ammount
            of Influence and Reputation, credits stored in gang safes count for more.
          </Stack.Item>
          <Stack.Item>
            -Drugs: The purchaseable gang dispenser containts formaltenamine which when metabolized by non gang members grants a
            Influence and Reputation.
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
