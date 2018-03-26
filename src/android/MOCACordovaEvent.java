package com.innoquant.moca.phonegap;

import android.os.SystemClock;
import android.support.annotation.NonNull;
import android.util.Log;

import com.innoquant.moca.MOCA;
import com.innoquant.moca.MOCAAction;
import com.innoquant.moca.core.MOCAContext;
import com.innoquant.moca.proximity.Action;
import com.innoquant.moca.proximity.ActionHandler;
import com.innoquant.moca.proximity.ProximityManager;
import com.innoquant.moca.proximity.Situation;
import com.innoquant.moca.proximity.campaign.Experience;
import com.innoquant.moca.proximity.handler.ActionCentral;
import com.innoquant.moca.proximity.handler.DefaultActionHandler;
import com.innoquant.moca.utils.logger.MLog;

/**
 * Wrapper class of MOCA delivered events.
 */
class MOCACordovaEvent {
    static final long EXPIRE_TIME_MS = 3 * 1000;
    private final String eventName;
    private final Object data;
    private final long expireDate;
    private MOCACordovaAction mocaAction;

    MOCACordovaEvent(String eventName, MOCAAction mocaAction, Object data) {
        this.eventName = eventName;
        this.data = data;
        if (mocaAction != null) {
            this.mocaAction = new MOCACordovaAction(mocaAction);
        }
        expireDate = SystemClock.elapsedRealtime() + EXPIRE_TIME_MS;
    }

    boolean isExpired() {
        long currentTime = SystemClock.elapsedRealtime();
        return currentTime >= expireDate;
    }

    boolean hasAction() {
        return mocaAction != null;
    }

    String getEventName() {
        return eventName;
    }

    public Object getData() {
        return data;
    }

    void fireAction() {
        if (mocaAction != null) {
            MLog.d("\t\tEvent has an associated action. will fire");
            mocaAction.fire();
        }
        else {
            MLog.d("\t\tNo action associated with event. Ignoring.");
        }
    }

    private class MOCACordovaAction implements Action {
        private Action action;
        private ActionHandler defaultActionHandler;

        MOCACordovaAction(@NonNull Action action) {
            this.action = action;
            loadActionCentral();
        }

        MOCACordovaAction(@NonNull MOCAAction mocaAction) {
            this((Action) mocaAction);
        }

        private void loadActionCentral() {
            if (MOCA.initialized()) {
                MOCAContext libContext = MOCA.getLibContext();
                defaultActionHandler = new DefaultActionHandler((MOCA.LibContext) libContext);
            } else {
                MLog.wtf( "MOCA SDK has not been initialized!");
            }
        }

        boolean fire() {
            return action.fire(Situation.Proximity, defaultActionHandler);
        }

        @Override
        public Experience getExperience() {
            return action.getExperience();
        }

        @Override
        public boolean fire(Situation situation, ActionHandler actionHandler) {
            return false;
        }

        @Override
        public void assignExperience(Experience experience) {
            action.assignExperience(experience);
        }

        @Override
        public String getActionId() {
            return action.getActionId();
        }

        @Override
        public String getCaption() {
            return action.getCaption();
        }

        @Override
        public Object getContent() {
            return action.getContent();
        }

        @Override
        public String getBackgroundAlert() {
            return action.getBackgroundAlert();
        }

        @Override
        public String getCampaignId() {
            return action.getCampaignId();
        }
    }
}
